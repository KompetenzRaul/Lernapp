import 'videoElement.dart';

class VideoPlaylist {
  final playlistName;
  final List<VideoElement> playlistContent;

  const VideoPlaylist({
    required this.playlistName,
    required this.playlistContent
  });
}