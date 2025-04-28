import 'musicElement.dart';
import 'musicPlaylist.dart';
import 'videoElement.dart';
import 'videoPlaylist.dart';

class DummyData {
  static MusicPlaylist dummyDataMusic = MusicPlaylist(
      playlistName: "Test",
      playlistContent: <MusicElement>[
        MusicElement(name: "Hung Up", filePath: "sldfkj", artist: "Madonna", duration: 3.21),
        MusicElement(name: "Hung Up2", filePath: "sldfkj", artist: "Madonna", duration: 3.15),
        MusicElement(name: "Hung Up3", filePath: "sldfkj", artist: "Madonna", duration: 2.57),
        MusicElement(name: "Hung Up4", filePath: "sldfkj", artist: "Madonna", duration: 3.14),
      ]
  );

  static VideoPlaylist dummyDataVideo = VideoPlaylist(
    playlistName: "TestVids",
    playlistContent: <VideoElement>[
      VideoElement(name: "Gravitation", filePath: "sljdlfkje", duration: 7.26),
      VideoElement(name: "Ellipse", filePath: "sljdlfkje", duration: 11.37),
      VideoElement(name: "Planeten", filePath: "sljdlfkje", duration: 15.41),
    ]
  );
}
