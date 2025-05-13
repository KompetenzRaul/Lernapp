import 'package:flutter/material.dart';

class MusicElement{
  final String songName;
  final String artistName;
  final String albumArtImagePath;
  final String audioFilePath;
  final double duration;

  const MusicElement({required this.songName, required this.artistName, required this.albumArtImagePath, required this.audioFilePath,  required this.duration});

  ListTile toListTile() {
    return ListTile(
      title: Text(
        this.songName,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xff425159),
            letterSpacing: 0.6
        ),
      ),
      trailing: Text(
        duration.toString().replaceAll(".", ":"),
        style: TextStyle(
          fontSize: 14
        ),
      ),
      iconColor: Color(0xff425159),
      subtitle: Text(this.artistName),
    );
  }
}