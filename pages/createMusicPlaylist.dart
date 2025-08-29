import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

import '../datamodels/musicPlaylist.dart';
import '../datamodels/musicElement.dart';
import '../datamodels/musicPlaylistProvider.dart';

class CreateMusicPlaylistPage extends StatefulWidget {
  const CreateMusicPlaylistPage({super.key});

  @override
  State<CreateMusicPlaylistPage> createState() => _CreateMusicPlaylistPageState();
}

class _CreateMusicPlaylistPageState extends State<CreateMusicPlaylistPage> {
  // Lokale Arbeitskopie (für Vorschau in der Liste)
  MusicPlaylist _playlist = MusicPlaylist(playlistName: 'Neue Playlist', playlistContent: []);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _playlistNameController = TextEditingController();
  final _uuid = const Uuid();

  bool _isPicking = false;
  bool _saving = false;

  // Firestore-Dokument-ID der angelegten Playlist
  String? _playlistId;

  @override
  void initState() {
    super.initState();
    _playlistNameController.text = _playlist.playlistName;
  }

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    setState(() => _playlist.playlistName = _playlistNameController.text.trim());
  }

  Future<bool> _ensureStoragePermission() async {
    if (!Platform.isAndroid) return true;

    var status = await Permission.storage.status;
    if (status.isGranted) return true;

    status = await Permission.storage.request();
    if (status.isGranted) return true;

    // (Optional) neuere Medienrechte
    final audioStatus = await Permission.audio.request();
    if (audioStatus.isGranted) return true;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speicherzugriff benötigt, um Dateien auszuwählen.')),
      );
    }
    return false;
  }

  Future<void> _onPickFiles() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final ok = await _ensureStoragePermission();
      if (!ok) {
        setState(() => _isPicking = false);
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ['mp3', 'm4a', 'aac', 'wav', 'flac', 'ogg'],
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isPicking = false);
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final List<MusicElement> pickedElements = [];

      for (final f in result.files) {
        final path = f.path;
        if (path == null) continue;

        try {
          final md = await MetadataGod.readMetadata(file: path);

          final String title = (md.title?.trim().isNotEmpty == true)
              ? md.title!.trim()
              : p.basenameWithoutExtension(path);

          final String artist = (md.artist?.trim().isNotEmpty == true)
              ? md.artist!.trim()
              : 'Unknown Artist';

          final double durationSeconds =
              (md.durationMs != null && md.durationMs! > 0) ? md.durationMs! / 1000.0 : 0.0;

          // Cover (falls vorhanden) temporär speichern
          String albumArtPath = "";
          final Uint8List? coverBytes = md.picture?.data;
          if (coverBytes != null && coverBytes.isNotEmpty) {
            final ext = (md.picture?.mimeType?.toLowerCase().contains('png') ?? false) ? 'png' : 'jpg';
            final artFile = File(
              p.join(tempDir.path, 'album_art_${DateTime.now().microsecondsSinceEpoch}.$ext'),
            );
            await artFile.writeAsBytes(coverBytes, flush: true);
            albumArtPath = artFile.path;
          }

          final item = MusicElement(
            name: title,
            filePath: path, // echter Gerätepfad
            artist: artist,
            duration: durationSeconds,
            albumArtImagePath: albumArtPath,
          )..uid = _uuid.v4();

          pickedElements.add(item);
        } catch (_) {
          final item = MusicElement(
            name: p.basenameWithoutExtension(path),
            filePath: path,
            artist: 'Unknown Artist',
            duration: 0.0,
            albumArtImagePath: "",
          )..uid = _uuid.v4();
          pickedElements.add(item);
        }
      }

      if (pickedElements.isNotEmpty) {
        // Sofort lokal anzeigen
        setState(() => _playlist.playlistContent.addAll(pickedElements));

        if (_playlistId != null) {
          // Wenn Playlist schon existiert → direkt in Firestore hinzufügen
          final provider = context.read<MusicPlaylistProvider>();
          for (final item in pickedElements) {
            await provider.addToPlaylist(playlistId: _playlistId!, item: item);
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${pickedElements.length} Datei(en) hinzugefügt ✅')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${pickedElements.length} Datei(en) hinzugefügt (lokal)')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Auswählen: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _onCreatePressed() async {
    if (_playlist.playlistName.trim().isEmpty || _playlist.playlistContent.isEmpty) return;

    setState(() => _saving = true);
    try {
      final provider = context.read<MusicPlaylistProvider>();

      // 1) Playlist in Firestore anlegen (falls noch nicht geschehen)
      _playlistId ??= await provider.createPlaylist(_playlist.playlistName);

      // 2) Alle lokal vorhandenen Items hochladen
      for (final item in _playlist.playlistContent) {
        await provider.addToPlaylist(playlistId: _playlistId!, item: item);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Playlist erstellt & Titel hochgeladen ✅')),
        );
        Navigator.of(context).pop<MusicPlaylist>(_playlist);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Erstellen: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showRenameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text("Bearbeiten")),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _playlistNameController,
              decoration: const InputDecoration(labelText: "Name der Playlist"),
              maxLength: 20,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Abbrechen"),
            ),
            FilledButton(
              onPressed: () {
                _submitForm();
                Navigator.of(context).pop();
              },
              child: const Text("Speichern"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCreate =
        _playlist.playlistContent.isNotEmpty && _playlist.playlistName.trim().isNotEmpty;

    // EXISTIERENDE MUSIK-PLAYLISTS (aus Provider)
    final existing = context.watch<MusicPlaylistProvider>().allPlaylists;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xffb70036),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        title: const Text(
          "Viducate",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
            fontSize: 32,
            letterSpacing: 0.8,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Musik Playlist erstellen",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Color(0xff425159),
              ),
            ),
            const SizedBox(height: 12),

            // Vorhandene Playlists (kompakter Block)
            if (existing.isNotEmpty) ...[
              const Text("Vorhandene Playlists",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: existing.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final pl = existing[i];
                    return Container(
                      width: 160,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
                      ),
                      child: Center(
                        child: Text(
                          pl.playlistName,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Overflow-sicher (wie bei Video)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          _playlist.playlistName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                            color: Color(0xff425159),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      IconButton(
                        onPressed: () => _showRenameDialog(context),
                        icon: const Icon(Icons.edit),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      child: FloatingActionButton.extended(
                        onPressed: _isPicking ? null : _onPickFiles,
                        label: Text(
                          _isPicking ? "Lade..." : "Dateien öffnen",
                          style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
                        ),
                        icon: _isPicking
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload),
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xffb70036),
                        elevation: 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView.separated(
                  itemCount: _playlist.playlistContent.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(color: Color(0xff425159)),
                  itemBuilder: (BuildContext context, int index) {
                    final el = _playlist.playlistContent[index];
                    return GestureDetector(
                      child: el.toListTile(),
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Titel entfernen?'),
                            content: Text('„${el.name}“ aus der Playlist löschen?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Abbrechen'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  setState(() => _playlist.playlistContent.removeAt(index));
                                  Navigator.pop(context);
                                  // Optional: Firestore-Remove
                                },
                                child: const Text('Löschen'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: FloatingActionButton.extended(
                onPressed: (_saving || !canCreate) ? null : _onCreatePressed,
                extendedPadding: const EdgeInsets.symmetric(horizontal: 120),
                label: Text(_saving ? "Erstelle..." : "Erstellen",
                    style: const TextStyle(fontSize: 15, letterSpacing: 0.5)),
                icon: const Icon(Icons.check),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xffb70036),
                elevation: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
