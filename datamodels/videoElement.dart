import 'package:uid/uid.dart';
import 'package:flutter/material.dart';

class VideoElement {
  String name;
  String filePath;
  double duration;
  late String uid;

  VideoElement({
    required this.name,
    required this.filePath,
    required this.duration,
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
      subtitle: Text(this.filePath),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'filePath': filePath,
      'duration': duration,
      'uid': uid,
      'createdAt': DateTime.now().millisecondsSinceEpoch, // optional
    };
  }

  factory VideoElement.fromMap(Map<String, dynamic> map) {
    final v = VideoElement(
      name: map['name'] ?? '',
      filePath: map['filePath'] ?? '',
      duration: (map['duration'] as num?)?.toDouble() ?? 0.0,
    );
    v.uid = map['uid'] ?? '';
    return v;
  }
}
