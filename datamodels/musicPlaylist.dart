import 'package:flutter/material.dart';
import 'musicElement.dart';

class MusicPlaylist extends ChangeNotifier {
  String playlistName;
  List<MusicElement> playlistContent;

  MusicPlaylist({required this.playlistName, required this.playlistContent});

  Map<String, dynamic> toMap() => {
    'name': playlistName,
    'createdAt': DateTime.now().millisecondsSinceEpoch,
  };

  factory MusicPlaylist.fromMap(
    Map<String, dynamic> map,
    List<MusicElement> items,
  ) {
    return MusicPlaylist(
      playlistName: map['name'] ?? '',
      playlistContent: items,
    );
  }
}
