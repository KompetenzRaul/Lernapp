import 'package:flutter/material.dart';

import 'musicPlayer.dart';
import 'videoPlayer.dart';

class PlayerController extends StatefulWidget {
  final double mediaRatio;
  const PlayerController({super.key, required this.mediaRatio});

  @override
  State<PlayerController> createState() => _PlayerControllerState();
}

class _PlayerControllerState extends State<PlayerController> {

  double _videoTime = 0.0;  // accumulierte Video-Laufzeit in Sekunden
  double _audioTime = 0.0; 

  @override
  Widget build(BuildContext context) {
    print("Media Ratio: ${widget.mediaRatio}");
    print("current ratio: ${_videoTime/(_videoTime+_audioTime)}");
    print("Video Time: $_videoTime, Audio Time: $_audioTime");
    dynamic randomChoice() {
      if (_videoTime/(_videoTime+_audioTime) < widget.mediaRatio) {
        return Videoplayer(key: UniqueKey(), videoPath: "assets/Ellipse.mp4", onVideoEnd: onFinishedVideo);
      } else {
        return MusicPlayer(key: UniqueKey(), onFinished: onFinishedAudio);
      }
      
    }
    return randomChoice();
  }

    void onFinishedVideo(double timePlayed) {
    setState(() {
      _videoTime += timePlayed;
    });
  }

  void onFinishedAudio(double timePlayed) {
    setState(() {
      _audioTime += timePlayed;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}