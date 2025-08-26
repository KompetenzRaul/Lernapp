import 'package:flutter/material.dart';

import 'musicElement.dart';

class MusicPlaylist extends ChangeNotifier{
  String playlistName;
  List<MusicElement> playlistContent;

  MusicPlaylist({
    required this.playlistName,
    required this.playlistContent,
  });
}
