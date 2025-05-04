import 'package:flutter/material.dart';

class MusicElement{
  final String name;
  final String filePath;
  final String artist;
  final double duration;

  const MusicElement({required this.name, required this.filePath, required this.artist, required this.duration});

  ListTile toListTile() {
    return ListTile(
      title: Text(
        this.name,
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
      subtitle: Text(this.artist),
    );
  }
}