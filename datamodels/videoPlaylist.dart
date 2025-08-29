import 'videoElement.dart';

class VideoPlaylist {
  String playlistName;
  List<VideoElement> playlistContent;

  VideoPlaylist({required this.playlistName, required this.playlistContent});
  Map<String, dynamic> toMap() => {
    'name': playlistName,
    'createdAt': DateTime.now().millisecondsSinceEpoch,
  };

  factory VideoPlaylist.fromMap(
    Map<String, dynamic> map,
    List<VideoElement> items,
  ) {
    return VideoPlaylist(
      playlistName: map['name'] ?? '',
      playlistContent: items,
    );
  }
}
