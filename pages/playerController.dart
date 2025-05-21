import 'package:flutter/material.dart';

import 'musicPlayer.dart';
import 'videoPlayer.dart';

class PlayerController extends StatefulWidget {
  const PlayerController({super.key});

  @override
  State<PlayerController> createState() => _PlayerControllerState();
}

class _PlayerControllerState extends State<PlayerController> {
  @override
  Widget build(BuildContext context) {
    dynamic randomChoice() {
      if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
        return Videoplayer();
      } else {
        return MusicPlayer();
      }
    }
    return randomChoice();
  }
}