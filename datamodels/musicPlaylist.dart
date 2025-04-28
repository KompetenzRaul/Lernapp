import 'musicElement.dart';

class MusicPlaylist{
  final String playlistName;
  final List<MusicElement> playlistContent;

  const MusicPlaylist({
    required this.playlistName,
    required this.playlistContent
  });
}