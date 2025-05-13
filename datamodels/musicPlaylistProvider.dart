import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dummyData.dart';
import 'musicElement.dart';
import 'package:flutter/widgets.dart';

class MusicPlaylistProvider extends ChangeNotifier{

  //current song playing index
  int? _currentSongIndex = 0;
  /* 
  
  A U D I O P L A Y E R

   */

  //audioplayer
  final AudioPlayer _audioPlayer = AudioPlayer();

  //durations
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  //constructor
  MusicPlaylistProvider() {
    listenToDuration();
  }

  // initially not playing 
  bool _isPlaying = false;

  // play the song
  void play() async {
    final String path = playlist[_currentSongIndex!].audioFilePath;
    await _audioPlayer.stop(); // stop current song
    await _audioPlayer.play(AssetSource(path)); // play the new song
    print(path);
    _isPlaying = true;
    notifyListeners();
  }

  //pause current song
  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  // resume playing
  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  // pause of resume
  void pauseOrResume() {
    if (_isPlaying) {
      pause();
    } else {
      resume();
      currentSongIndex = _currentSongIndex;
    }
    notifyListeners();
  }

  //seek to specific position in the current song
  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // play next song
  void playNextSong() {
    if (_currentSongIndex != null) {
      if (_currentSongIndex! < playlist.length -1) {
        // go to the next song if it is not the last song
        currentSongIndex =_currentSongIndex! +1;
      } else {
        // if it is the last song, loop back to the first song
        currentSongIndex = 0;
      }
    }
  }

  // play previous song
  void playPreviousSong() async {
    // if more than 2 seconds have passed, restart the current song
    if (_currentDuration.inSeconds > 2) {
      seek(Duration.zero);
    }
    // it it is within the first 2 seconds of the song, go to the previous song
    else {
      if (_currentSongIndex! > 0) {
        currentSongIndex = _currentSongIndex! -1;
      } else {
        // if it is the first song, loop back to the last song
        currentSongIndex = playlist.length -1;
      }
    }
  }

  // listen to duration
  void listenToDuration() {

    //listen for total duration
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration; 
      notifyListeners();
    });

    // listen for current duration
    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition; 
      notifyListeners();
    });

    //listen for song completion
    _audioPlayer.onPlayerComplete.listen((event) {
      playNextSong();
    });
     

  }

  // dispose audio player
  void disposeOfAudioPlayer() {
    _audioPlayer.dispose();
  }



  /* 
  
  G E T T E R S
  
   */
  
  List<MusicElement> get playlist => DummyData().songs;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get totalDuration => _totalDuration;
  Duration get currentDuration => _currentDuration;

  /* 

    S E T T E R S

  */

  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;
    if (newIndex != null) {
      play(); // play the song at the new index
    }
    notifyListeners();
  }

}
