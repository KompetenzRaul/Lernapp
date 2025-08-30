import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../datamodels/videoPlaylist.dart';
import '../datamodels/videoElement.dart';
import '../repository/firestore_repository.dart';
import '../datamodels/videoPlaylistProvider.dart';

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
    // Android: request videos permission on Android 13+; fallback to storage on older devices.
    if (Platform.isAndroid) {
      // Prefer the Android 13+ scoped media permission for videos
      var videoStatus = await Permission.videos.status;
      if (!videoStatus.isGranted) {
        videoStatus = await Permission.videos.request();
      }
      if (videoStatus.isGranted) return true;

      // Fallback for older Android versions where READ_EXTERNAL_STORAGE was used
      var storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.storage.request();
      }
      if (storageStatus.isGranted) return true;

      // If permanently denied, offer to open settings
      final permanentlyDenied =
          await Permission.videos.isPermanentlyDenied ||
          await Permission.storage.isPermanentlyDenied;
      if (permanentlyDenied && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Zugriff auf Videos ist deaktiviert. Bitte in den Einstellungen erlauben.',
            ),
            action: SnackBarAction(
              label: 'Einstellungen',
              onPressed: openAppSettings,
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speicher-/Videozugriff benötigt, um Dateien auszuwählen.'),
          ),
        );
      }
      return false;
    }

    // iOS: request Photos permission when needed (FilePicker may use Files app and not require it)
    if (Platform.isIOS) {
      var photos = await Permission.photos.status;
      if (!photos.isGranted) {
        photos = await Permission.photos.request();
      }
      if (photos.isGranted) return true;

      if (await Permission.photos.isPermanentlyDenied && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Fotos/Videos Zugriff ist deaktiviert. Bitte in den Einstellungen erlauben.',
            ),
            action: SnackBarAction(
              label: 'Einstellungen',
              onPressed: openAppSettings,
            ),
          ),
        );
      }
      return false;
    }

    // Other platforms
    return true;
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
        allowedExtensions: ['mp4', 'mkv', 'mov'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isPicking = false);
        return;
      }

      final repo = FirestoreRepository();
      int addedCount = 0;

      // Helper to normalize picked file paths (avoid mistaken 'assets/' prefix)
      String _sanitizePickedPath(String original) {
        String p0 = original.replaceAll('\\', '/');
        if (p0.startsWith('assets/')) {
          p0 = p0.replaceFirst(RegExp(r'^assets/+'), '');
        }
        p0 = p0.replaceFirst(RegExp(r'^/+'), '/');
        return p0;
      }

  // Prepare persistent storage directory
      final docsDir = await getApplicationDocumentsDirectory();
      final videoTargetDir = Directory(p.join(docsDir.path, 'media', 'video'));
      if (!await videoTargetDir.exists()) {
        await videoTargetDir.create(recursive: true);
      }
      String _uniqueName(String base) {
        final ts = DateTime.now().microsecondsSinceEpoch;
        final name = p.basenameWithoutExtension(base);
        final ext = p.extension(base);
        final safeName = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
        return '${safeName}_$ts$ext';
      }

      for (final f in result.files) {
        final path = f.path;
        if (path == null) continue;
        final safePath = _sanitizePickedPath(path);
        // Persist only when needed to avoid double usage: move from temp if necessary
        String storedPath = safePath;
        try {
          final src = File(safePath);
          if (await src.exists()) {
            final tmpDir = await getTemporaryDirectory();
            final isFromTemp = safePath.replaceAll('\\', '/').startsWith(
              tmpDir.path.replaceAll('\\', '/'),
            );
            if (isFromTemp) {
              final dest = p.join(videoTargetDir.path, _uniqueName(p.basename(safePath)));
              try {
                final moved = await src.rename(dest);
                storedPath = moved.path;
              } catch (_) {
                await src.copy(dest);
                storedPath = dest;
                try { await src.delete(); } catch (_) {}
              }
            } else {
              storedPath = safePath;
            }
          }
        } catch (e) {
          debugPrint('Video persist/move failed: $e');
        }

        // Dauer via video_player auslesen
  final controller = VideoPlayerController.file(File(storedPath));
        await controller.initialize();
        final duration = controller.value.duration;
        await controller.dispose();

        final filename = f.name.isNotEmpty ? f.name : p.basename(storedPath);
        final item = VideoElement(
          name: p.basenameWithoutExtension(filename),
          filePath: storedPath,
          duration: duration.inSeconds.toDouble(),
        )..uid = ''; // optional, falls du uid nutzt

        // Sofort in UI-Liste
        setState(() => _playlist.playlistContent.add(item));

        // Falls Playlist bereits existiert → direkt hochladen
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

  Future<void> _showRenameDialog(BuildContext context) async {
    final TextEditingController controller =
        TextEditingController(text: _playlist.playlistName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Playlist umbenennen'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Neuer Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _playlist.playlistName = controller.text.trim();
                _playlistNameController.text = controller.text.trim();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCreate =
        _playlist.playlistContent.isNotEmpty &&
        _playlist.playlistName.trim().isNotEmpty;

    // EXISTIERENDE VIDEO-PLAYLISTS (aus Provider)
    final existing = context.watch<VideoPlaylistProvider>().allPlaylists;

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
            const SizedBox(height: 12),

            // Vorhandene Playlists (kompakter Block, UI bleibt clean)
            if (existing.isNotEmpty) ...[
              const Text(
                "Vorhandene Playlists",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
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
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 3),
                        ],
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
                        onPressed: _isPicking ? null : _pickVideo,
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

            const SizedBox(height: 10),

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
