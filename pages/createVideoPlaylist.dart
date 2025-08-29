import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart'; // optional, falls wir später Thumbnails cachen wollen
import 'package:permission_handler/permission_handler.dart';

import '../datamodels/videoPlaylist.dart';
import '../datamodels/videoElement.dart';
import '../repository/firestore_repository.dart';

class CreateVideoPlaylistPage extends StatefulWidget {
  const CreateVideoPlaylistPage({super.key});

  @override
  State<CreateVideoPlaylistPage> createState() =>
      _CreateVideoPlaylistPageState();
}

class _CreateVideoPlaylistPageState extends State<CreateVideoPlaylistPage> {
  // Lokale Arbeitskopie (für Vorschau in der Liste)
  VideoPlaylist _playlist = VideoPlaylist(
    playlistName: 'Neue Video-Playlist',
    playlistContent: [],
  );

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _playlistNameController = TextEditingController();

  // Firestore-Dokument-ID der angelegten Playlist
  String? _playlistId;

  bool _isPicking = false;
  bool _saving = false;

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

  void submitForm() {
    setState(
      () => _playlist.playlistName = _playlistNameController.text.trim(),
    );
  }

  Future<bool> _ensureStoragePermission() async {
    // Für Android Storage-Rechte anfragen (iOS braucht’s i. d. R. nicht)
    if (!Platform.isAndroid) return true;

    var status = await Permission.storage.status;
    if (status.isGranted) return true;

    status = await Permission.storage.request();
    if (status.isGranted) return true;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speicherzugriff benötigt, um Dateien auszuwählen.'),
        ),
      );
    }
    return false;
  }

  Future<void> _pickVideo() async {
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
        allowedExtensions: [
          'mp4',
          'mkv',
          'mov',
        ], // mp4 reicht meist; mkv/mov optional
        allowMultiple: true, // mehrere auf einmal möglich (UI bleibt gleich)
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isPicking = false);
        return;
      }

      final repo = FirestoreRepository();
      int addedCount = 0;

      for (final f in result.files) {
        final path = f.path;
        if (path == null) continue;

        // Dauer via video_player auslesen
        final controller = VideoPlayerController.file(File(path));
        await controller.initialize();
        final duration = controller.value.duration;
        await controller.dispose();

        final filename = f.name.isNotEmpty ? f.name : p.basename(path);
        final item = VideoElement(
          name: p.basenameWithoutExtension(filename),
          filePath: path,
          duration: duration.inSeconds.toDouble(),
        )..uid = ''; // optional, falls du uid nutzt

        // Sofort in UI-Liste
        setState(() => _playlist.playlistContent.add(item));

        // Falls Playlist bereits in Firestore existiert → direkt hochladen
        if (_playlistId != null) {
          await repo.addVideoItem(_playlistId!, item);
          addedCount++;
        }
      }

      if (mounted) {
        if (_playlistId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$addedCount Video(s) hinzugefügt ✅')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${result.files.length} Video(s) hinzugefügt (lokal)',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Auswählen: $e')));
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
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
              decoration: const InputDecoration(labelText: "Name"),
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
                submitForm();
                Navigator.of(context).pop();
              },
              child: const Text("Speichern"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onCreatePressed() async {
    if (_playlist.playlistName.trim().isEmpty ||
        _playlist.playlistContent.isEmpty)
      return;

    setState(() => _saving = true);
    try {
      final repo = FirestoreRepository();

      // 1) Playlist anlegen (falls noch nicht geschehen)
      _playlistId ??= await repo.createVideoPlaylist(_playlist.playlistName);

      // 2) Alle lokal vorhandenen Items hochladen
      for (final item in _playlist.playlistContent) {
        await repo.addVideoItem(_playlistId!, item);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video-Playlist erstellt & Videos hochgeladen ✅'),
          ),
        );
        Navigator.of(context).pop<VideoPlaylist>(_playlist);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Erstellen: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCreate =
        _playlist.playlistContent.isNotEmpty &&
        _playlist.playlistName.trim().isNotEmpty;

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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "Video Playlist erstellen",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Color(0xff425159),
              ),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Linke Seite: Name + Edit
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

                // Rechte Seite: FAB passt sich an verfügbaren Platz an
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      child: FloatingActionButton.extended(
                        onPressed:
                            _isPicking
                                ? null
                                : _pickVideo, // bzw. _onPickFiles bei Musik
                        label: Text(
                          _isPicking ? "Lade..." : "Dateien öffnen",
                          style: const TextStyle(
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                        icon:
                            _isPicking
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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

            SizedBox(height: 10),

            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  itemCount: _playlist.playlistContent.length,
                  separatorBuilder:
                      (BuildContext context, int index) =>
                          const Divider(color: Color(0xff425159)),
                  itemBuilder: (BuildContext context, int index) {
                    return _playlist.playlistContent[index].toListTile();
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // (Dein zweites Expanded mit derselben Liste lasse ich unangetastet,
            //  damit die UI identisch bleibt. Es zeigt dieselben Items.)
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  itemCount: _playlist.playlistContent.length,
                  separatorBuilder:
                      (BuildContext context, int index) =>
                          const Divider(color: Color(0xff425159)),
                  itemBuilder: (BuildContext context, int index) {
                    return _playlist.playlistContent[index].toListTile();
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: FloatingActionButton.extended(
                onPressed: (_saving || !canCreate) ? null : _onCreatePressed,
                extendedPadding: const EdgeInsets.symmetric(horizontal: 120),
                label: Text(
                  _saving ? "Erstelle..." : "Erstellen",
                  style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
                ),
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
