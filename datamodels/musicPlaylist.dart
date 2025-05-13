import 'package:flutter/material.dart';

import 'musicElement.dart';

class MusicPlaylist extends ChangeNotifier{
  final String playlistName;
  final List<MusicElement> playlistContent;

  MusicPlaylist({
    required this.playlistName,
    required this.playlistContent,
  });
}
