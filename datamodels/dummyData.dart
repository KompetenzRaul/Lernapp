import 'musicElement.dart';
import 'musicPlaylist.dart';
import 'videoElement.dart';
import 'videoPlaylist.dart';

class DummyData{
  static MusicPlaylist dummyDataMusic = MusicPlaylist(
      playlistName: "Test",
      playlistContent: <MusicElement>[
        MusicElement(name: "Song 1", filePath: "../assets/audio/test_song_1.mp3", artist: "test1", duration: 3.13, albumArtImagePath: 'assets/images/test_image_1.png'),
        MusicElement(name: "Song 2", filePath: "../assets/audio/test_song_2.mp3", artist: "test2", duration: 3.12, albumArtImagePath: 'assets/images/test_image_2.png'),
        MusicElement(name: "Song 3", filePath: "../assets/audio/test_song_3.mp3", artist: "test3", duration: 3.22, albumArtImagePath: 'assets/images/test_image_3.png'),
      ]
  );

  /* 
  
  G E T T E R S
  
   */
    List<MusicElement> get songs => dummyDataMusic.playlistContent;


  static VideoPlaylist dummyDataVideo = VideoPlaylist(
    playlistName: "TestVids",
    playlistContent: <VideoElement>[
      VideoElement(name: "Gravitation", filePath: "sljdlfkje", duration: 7.26),
      VideoElement(name: "Ellipse", filePath: "sljdlfkje", duration: 11.37),
      VideoElement(name: "Planeten", filePath: "sljdlfkje", duration: 15.41),
    ]
  );
}




