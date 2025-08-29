import 'package:flutter/material.dart';
import 'package:uid/uid.dart';

class MusicElement {
  String name;
  String filePath;
  String artist;
  late String uid;
  double duration;
  String albumArtImagePath;

  MusicElement({
    required this.name,
    required this.filePath,
    required this.artist,
    required this.duration,
    required this.albumArtImagePath,
  }) {
    this.uid = UId.getId();
  }

  ListTile toListTile() {
    return ListTile(
      title: Text(
        this.name,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color(0xff425159),
          letterSpacing: 0.6,
        ),
      ),
      trailing: Text(
        duration.toString().replaceAll(".", ":"),
        style: TextStyle(fontSize: 14),
      ),
      iconColor: Color(0xff425159),
      subtitle: Text(this.uid),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'filePath': filePath,
      'artist': artist,
      'uid': uid,
      'duration': duration,
      'albumArtImagePath': albumArtImagePath,
    };
  }

  factory MusicElement.fromMap(Map<String, dynamic> map) {
    return MusicElement(
      name: map['name'] ?? '',
      filePath: map['filePath'] ?? '',
      artist: map['artist'] ?? '',
      duration: (map['duration'] as num?)?.toDouble() ?? 0.0,
      albumArtImagePath: map['albumArtImagePath'] ?? '',
    )..uid = map['uid'] ?? '';
  }
}
