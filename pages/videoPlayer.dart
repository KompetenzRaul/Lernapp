import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

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

  Future<void> _initializePlayer() async {
    _hasEnded = false; // Reset beim Initialisieren
    _videoPlayerController = VideoPlayerController.asset(widget.videoPath);

    await _videoPlayerController.initialize();

    _onVideoEndListener = () {
      final value = _videoPlayerController.value;
      // Toleranz von 500ms, falls position minimal kleiner als duration ist
      final isEnded = value.isInitialized &&
        !value.isPlaying &&
        (value.duration.inMilliseconds > 0) &&
        (value.position.inMilliseconds >= value.duration.inMilliseconds - 500);
      if (isEnded && !_hasEnded) {
        _hasEnded = true;
        if (widget.onVideoEnd != null) {
          print("Video has ended, calling callback.");
          _chewieController?.exitFullScreen();
          widget.onVideoEnd!(_chewieController!.videoPlayerController.value.duration.inSeconds.toDouble());
        }
      }
    };
    _videoPlayerController.addListener(_onVideoEndListener!);

    final controller = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      fullScreenByDefault: true,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      customControls: const MaterialControls(),
      zoomAndPan: true,
      hideControlsTimer: const Duration(seconds: 3),
      progressIndicatorDelay:const Duration(days: 1), // Es gibt gerade ein Bug in Chewie der verhindert, dass der Ladespinner verschwindet wenn er einmal auftaucht.
      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: (context) {
              // Handle option tap
              print('Video Merken $context');
            },
            iconData: Icons.note,
            title: 'Video Merken',
          ),
        ];
      },
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
                    bottomRight: Radius.circular(15)
                )
            ),
            backgroundColor: Color(0xffb70036),
            title: const Text(
              "Viducate",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 32,
                  letterSpacing: 0.8
            ),
        ))
            : null,
        body: Column(
          children: [
            SizedBox(height: 20),
            _chewieController != null
                ? AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            )
                : const Center(child: CircularProgressIndicator()),
            if (isPortrait) Expanded(flex: 2, child: Placeholder()),
          ],
        )
    );
  }
}
