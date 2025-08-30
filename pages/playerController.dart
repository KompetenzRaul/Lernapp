import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'musicPlayer.dart';
import 'videoPlayer.dart';
import '../datamodels/videoPlaylistProvider.dart';

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
    final total = _videoTime + _audioTime;
    final currentRatio = total > 0 ? _videoTime / total : 0.0;
    print("Media Ratio: ${widget.mediaRatio}");
    print("current ratio: $currentRatio");
    print("Video Time: $_videoTime, Audio Time: $_audioTime");

    final videoProvider = context.watch<VideoPlaylistProvider>();
    final hasVideo = videoProvider.playlist.isNotEmpty &&
        videoProvider.currentVideoIndex != null &&
        videoProvider.currentVideoIndex! < videoProvider.playlist.length;
    final videoPath = hasVideo
        ? videoProvider.playlist[videoProvider.currentVideoIndex!].filePath
        : null;

    if (currentRatio < widget.mediaRatio && videoPath != null && videoPath.isNotEmpty) {
      return Videoplayer(
        key: UniqueKey(),
        videoPath: videoPath,
        onVideoEnd: (secs) {
          onFinishedVideo(secs);
          videoProvider.playNext();
        },
      );
    }
    return MusicPlayer(key: UniqueKey(), onFinished: onFinishedAudio);
  }

    void onFinishedVideo(double timePlayed) {
      print("Video finished: $timePlayed");
    setState(() {
      _videoTime += timePlayed;
    });
  }

  void onFinishedAudio(double timePlayed) {
    print("Audio finished: $timePlayed");
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