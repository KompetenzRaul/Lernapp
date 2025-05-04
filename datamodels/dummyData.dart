import 'musicElement.dart';
import 'musicPlaylist.dart';
import 'videoElement.dart';
import 'videoPlaylist.dart';

class DummyData {
  static MusicPlaylist dummyDataMusic = MusicPlaylist(
      playlistName: "Test",
      playlistContent: <MusicElement>[
        MusicElement(name: "Song 1", filePath: "sldfkj", artist: "irgendwer", duration: 3.21),
        MusicElement(name: "Song 2", filePath: "sldfkj", artist: "irgendwer", duration: 3.15),
        MusicElement(name: "Song 3", filePath: "sldfkj", artist: "irgendwer", duration: 2.57),
        MusicElement(name: "Song 4", filePath: "sldfkj", artist: "irgendwer", duration: 3.14),
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
