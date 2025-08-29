import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// Deine Models
import '../datamodels/musicElement.dart';
import '../datamodels/musicPlaylist.dart';

// Firestore-Repo
import '../repository/firestore_repository.dart';

class MusicPlaylistProvider extends ChangeNotifier {
  MusicPlaylistProvider(this._repo, {this.onFinished}) {
    // Audio-Events abonnieren (wie zuvor)
    _durationSubscription = _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });
    _positionSubscription = _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });
    _completionSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      final played = _totalDuration.inSeconds.toDouble();
      if (onFinished != null) onFinished!(played);
      playNextSong();
    });
  }

  final FirestoreRepository _repo;
  final ValueChanged<double>? onFinished;

  // ---------------------------
  // Firestore-Streams / State
  // ---------------------------
  StreamSubscription<List<MusicPlaylist>>? _playlistsSub;
  String? _activePlaylistId;

  // Die aktuell sichtbare/aktive Songliste (ersetzt DummyData().songs)
  List<MusicElement> _playlist = [];
  List<MusicElement> get playlist => _playlist;

  // Optional: Falls du die Liste der Playlists brauchst (UI bleibt aber unverändert)
  List<MusicPlaylist> _allPlaylists = [];
  List<MusicPlaylist> get allPlaylists => _allPlaylists;

  /// Startet das Abo: lädt alle Playlists + deren Items und setzt die aktive Playlist (falls nicht gesetzt) auf die erste.
  Future<void> start() async {
    await _playlistsSub?.cancel();
    _playlistsSub = _repo.streamMusicPlaylistsWithItems().listen((list) {
      _allPlaylists = list;

      // aktive Playlist ermitteln: gesetzt -> nehmen, sonst erste vorhandene
      String? id = _activePlaylistId;
      if (id == null && list.isNotEmpty) {
        // Wir nutzen hier implizit "die erste" Playlist, damit die UI ohne Änderung Daten erhält
        id = 'FIRST';
      }

      if (id != null) {
        if (id == 'FIRST' && list.isNotEmpty) {
          _playlist = list.first.playlistContent;
        } else {
          final found = list.firstWhere(
            (p) => p.playlistName == id, // falls du später mit Namen selektierst
            orElse: () => list.isNotEmpty ? list.first : MusicPlaylist(playlistName: '', playlistContent: []),
          );
          _playlist = found.playlistContent;
        }

        // Falls der aktuelle Song-Index außerhalb der neuen Liste liegt, zurücksetzen
        if (_currentSongIndex != null && _playlist.isNotEmpty) {
          if (_currentSongIndex! >= _playlist.length) {
            _currentSongIndex = 0;
          }
        } else if (_playlist.isEmpty) {
          _currentSongIndex = null;
          _isPlaying = false;
          _audioPlayer.stop();
        }
      } else {
        _playlist = [];
        _currentSongIndex = null;
      }

      notifyListeners();
    }, onError: (e, st) {
      debugPrint('MusicPlaylistProvider stream error: $e');
    });
  }

  /// Optional: explizit eine aktive Playlist setzen (z. B. per ID/Name)
  /// Wenn ihr später Playlists per Document-ID auswählt, ändere hier die Logik passend.
  void setActivePlaylistByName(String name) {
    _activePlaylistId = name;
    // Beim nächsten Stream-Event wird _playlist entsprechend gesetzt.
    notifyListeners();
  }

  Future<void> stop() async {
    await _playlistsSub?.cancel();
    _playlistsSub = null;
  }

  // ---------------------------
  // AUDIOPLAYER (wie gehabt)
  // ---------------------------
  final AudioPlayer _audioPlayer = AudioPlayer();

  Duration _currentDuration = Duration.zero;
  Duration get currentDuration => _currentDuration;

  Duration _totalDuration = Duration.zero;
  Duration get totalDuration => _totalDuration;

  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<void>? _completionSubscription;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  int? _currentSongIndex = 0;
  int? get currentSongIndex => _currentSongIndex;

  // play the song
  Future<void> play() async {
    if (_currentSongIndex == null || _playlist.isEmpty) return;

    final String path = _playlist[_currentSongIndex!].filePath;

    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(path));
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  void pauseOrResume() {
    if (_isPlaying) {
      pause();
    } else {
      resume();
      currentSongIndex = _currentSongIndex;
    }
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void playNextSong() {
    if (_currentSongIndex != null && _playlist.isNotEmpty) {
      if (_currentSongIndex! < _playlist.length - 1) {
        currentSongIndex = _currentSongIndex! + 1;
      } else {
        currentSongIndex = 0;
      }
    }
  }

  void playPreviousSong() async {
    if (_currentDuration.inSeconds > 2) {
      await seek(Duration.zero);
    } else {
      if (_currentSongIndex != null && _currentSongIndex! > 0) {
        currentSongIndex = _currentSongIndex! - 1;
      } else {
        if (_playlist.isNotEmpty) {
          currentSongIndex = _playlist.length - 1;
        }
      }
    }
  }

  // SETTER: beim Wechsel des Index direkt abspielen (wie bisher)
  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;
    if (newIndex != null) {
      play();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _completionSubscription?.cancel();
    _playlistsSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
