import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class Videoplayer extends StatefulWidget {
  const Videoplayer({super.key});

  @override
  State<Videoplayer> createState() => _VideoplayerState();
}

class _VideoplayerState extends State<Videoplayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.asset("assets/Ellipse.mp4");

    await _videoPlayerController.initialize();

    final controller = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: true,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      customControls: const MaterialControls(),
      zoomAndPan: true,
      hideControlsTimer: const Duration(seconds: 3),
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
