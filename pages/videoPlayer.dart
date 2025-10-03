import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:io' as io;
import '../datamodels/error_markers.dart';
// import '../pages/error_markers_page.dart'; // entfernt (nicht genutzt)

import 'playerController.dart';

ChewieController _chewieOf(BuildContext context) =>
    ChewieController.of(context);
VideoPlayerController _videoOf(BuildContext context) =>
    _chewieOf(context).videoPlayerController;

class ViducateControls extends StatefulWidget {
  const ViducateControls({super.key, this.onBookmark});

  final VoidCallback? onBookmark;

  @override
  State<ViducateControls> createState() => _ViducateControlsState();
}

class _ViducateControlsState extends State<ViducateControls> {
  double _currentSpeed = 1.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // aktuellen Speed aus dem VideoController lesen
    _currentSpeed = _videoOf(context).value.playbackSpeed;
  }

  Future<void> _cycleSpeed() async {
    final v = _videoOf(context);
    final chewie = _chewieOf(context);

    final speeds =
        chewie.playbackSpeeds.isNotEmpty
            ? chewie.playbackSpeeds
            : const [0.5, 1.0, 1.25, 1.5, 1.75, 2.0];

    final idx = speeds.indexWhere((s) => (s - _currentSpeed).abs() < 0.0001);
    final next = speeds[(idx < 0 ? 0 : (idx + 1) % speeds.length)];

    await v.setPlaybackSpeed(next);
    setState(() => _currentSpeed = next);

    playbackSpeed = next;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MaterialControls(),

        Positioned(
          top: 1,
          right: 30,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  backgroundColor: Colors.black.withOpacity(0.55),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: _cycleSpeed,
                child: Text(
                  '${_currentSpeed.toStringAsFixed(_currentSpeed % 1 == 0 ? 0 : 2)}×',
                ),
              ),
              const SizedBox(width: 8),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  backgroundColor: Colors.black.withOpacity(0.55),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed:
                    widget.onBookmark ??
                    () async {
                      final position = _videoOf(context).value.position;

                      // Einen kurzen Namen abfragen (oder Default nehmen)
                      final raw = await _askForName(context);
                      final title =
                          (raw == null || raw.trim().isEmpty)
                              ? 'Unbenannter Fehler'
                              : raw.trim();

                      final mediaId = _videoOf(context).dataSource;

                      ErrorMarkersStore.instance.add(
                        mediaId: mediaId,
                        title: title,
                        position: position,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Marke gespeichert')),
                      );
                    },
                icon: const Icon(Icons.bookmark_border, size: 18),
                label: const Text('Merken'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Videoplayer extends StatefulWidget {
  const Videoplayer({super.key, required this.videoPath, this.onVideoEnd});

  final String videoPath;
  final ValueChanged<double>? onVideoEnd;

  @override
  State<Videoplayer> createState() => _VideoplayerState();
}

class _VideoplayerState extends State<Videoplayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasEnded = false; // Prevent multiple calls
  VoidCallback? _onVideoEndListener;

  // Normalize a path: if it starts with 'assets/' but the remainder looks like an absolute
  // device path (Android/iOS/Windows), strip the mistaken prefix.
  String _normalizeVideoPath(String originalPath) {
    String p = originalPath.replaceAll('\\', '/');
    if (!p.startsWith('assets/')) return originalPath;
    final String rest = p.substring('assets/'.length);
    final String r = rest.startsWith('/') ? rest.substring(1) : rest;
    final bool looksAndroidAbs =
        r.startsWith('data/') ||
        r.startsWith('storage/') ||
        r.startsWith('sdcard/') ||
        r.startsWith('mnt/');
    final bool looksIOSAbs =
        r.startsWith('var/') || r.startsWith('private/var/');
    final bool looksWindowsAbs = r.contains(':/');
    if (looksAndroidAbs || looksIOSAbs || looksWindowsAbs) {
      return r; // strip mistaken assets/ prefix
    }
    return originalPath;
  }

  Future<void> _initializePlayer() async {
    _hasEnded = false; // Reset beim Initialisieren
    final normalizedPath = _normalizeVideoPath(widget.videoPath);
    try {
      // Unterscheide verschiedene Quellen: Asset, file:// echter Pfad, content:// URI
      final src = widget.videoPath;
      final lower = src.toLowerCase();
      final isAsset = normalizedPath.startsWith('assets/');
      final isContent = lower.startsWith('content://');
      final looksAbsoluteFile = !isContent && !isAsset &&
          (lower.startsWith('/') || lower.contains(':\\') || lower.contains(':/'));

      if (isAsset) {
        debugPrint('[VideoInit] Asset source: $normalizedPath');
        _videoPlayerController = VideoPlayerController.asset(normalizedPath);
      } else if (isContent) {
        debugPrint('[VideoInit] Content URI source: $src');
        _videoPlayerController = VideoPlayerController.contentUri(Uri.parse(src));
      } else if (looksAbsoluteFile && io.File(src).existsSync()) {
        debugPrint('[VideoInit] File path source: $src');
        _videoPlayerController = VideoPlayerController.file(io.File(src));
      } else {
        // Fallback: versuche zuerst contentUri, dann file
        debugPrint('[VideoInit][WARN] Unklares Schema, versuche contentUri: $src');
        try {
          _videoPlayerController = VideoPlayerController.contentUri(Uri.parse(src));
        } catch (e) {
          debugPrint('[VideoInit][Fallback] contentUri fehlgeschlagen ($e), versuche file()');
          _videoPlayerController = VideoPlayerController.file(io.File(src));
        }
      }

      await _videoPlayerController.initialize();
      debugPrint('[VideoInit] Initialisiert. Dauer=${_videoPlayerController.value.duration} Aspect=${_videoPlayerController.value.aspectRatio}');
    } catch (e, st) {
      debugPrint('[VideoInit][ERROR] Initialisierung fehlgeschlagen: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video konnte nicht geladen werden: $e')),
        );
      }
      return; // Abbrechen, kein Chewie anlegen
    }

    _onVideoEndListener = () {
      final value = _videoPlayerController.value;
      // Toleranz von 500ms, falls position minimal kleiner als duration ist
      final isEnded =
          value.isInitialized &&
          !value.isPlaying &&
          (value.duration.inMilliseconds > 0) &&
          (value.position.inMilliseconds >=
              value.duration.inMilliseconds - 500);
      if (isEnded && !_hasEnded) {
        _hasEnded = true;
        if (widget.onVideoEnd != null) {
          debugPrint("Video has ended, calling callback.");
          _chewieController?.exitFullScreen();
          widget.onVideoEnd!(
            _chewieController!.videoPlayerController.value.duration.inSeconds
                .toDouble(),
          );
        }
      }
    };
    _videoPlayerController.addListener(_onVideoEndListener!);

    _videoPlayerController.setPlaybackSpeed(playbackSpeed);

    final controller = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      fullScreenByDefault: true,
      deviceOrientationsAfterFullScreen: const [DeviceOrientation.portraitUp],

      customControls: ViducateControls(),

      // Untermenü deaktivieren
      allowPlaybackSpeedChanging: false,
      zoomAndPan: true,
      hideControlsTimer: const Duration(seconds: 3),
      progressIndicatorDelay: const Duration(days: 1),

      playbackSpeeds: const [0.5, 1.0, 1.25, 1.5, 1.75, 2.0],
    );

    setState(() {
      _chewieController = controller;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    // letzte Speed merken (global)
    playbackSpeed = _videoPlayerController.value.playbackSpeed;

    _videoPlayerController.removeListener(_onVideoEndListener!);
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar:
          isPortrait
              ? AppBar(
                centerTitle: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                backgroundColor: const Color(0xffb70036),
                title: const Text(
                  "Viducate",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 32,
                    letterSpacing: 0.8,
                  ),
                ),
              )
              : null,
      body: Column(
        children: [
          const SizedBox(height: 20),
          _chewieController != null
              ? AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              )
              : const Center(child: CircularProgressIndicator()),
          if (isPortrait) const Expanded(flex: 2, child: Placeholder()),
        ],
      ),
    );
  }
}

Future<String?> _askForName(BuildContext context) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text('Fehler benennen'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(),
            onSubmitted: (_) => Navigator.of(ctx).pop(controller.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Markieren'),
            ),
          ],
        ),
  );
}
