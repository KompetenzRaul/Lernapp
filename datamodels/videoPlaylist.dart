import 'videoElement.dart';

class VideoPlaylist {
  String playlistName;
  List<VideoElement> playlistContent;

  VideoPlaylist({
    required this.playlistName,
    required this.playlistContent
  });
}