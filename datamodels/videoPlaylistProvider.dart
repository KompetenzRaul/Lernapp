import 'dart:async';
import 'package:flutter/foundation.dart';

import '../datamodels/videoElement.dart';
import '../datamodels/videoPlaylist.dart';
import '../repository/firestore_repository.dart';

class VideoPlaylistProvider extends ChangeNotifier {
  VideoPlaylistProvider(this._repo);

  final FirestoreRepository _repo;

  // Firestore-Stream
  StreamSubscription<List<VideoPlaylist>>? _playlistsSub;

  // alle Video-Playlists (falls du sie irgendwo listen willst)
  List<VideoPlaylist> _allPlaylists = [];
  List<VideoPlaylist> get allPlaylists => _allPlaylists;

  // aktive Playlist-Inhalte (ersetzt DummyData().videos)
  List<VideoElement> _playlist = [];
  List<VideoElement> get playlist => _playlist;

  // aktiver Index
  int? _currentVideoIndex = 0;
  int? get currentVideoIndex => _currentVideoIndex;

  // optional: aktive Playlist wählen (z. B. per Name)
  String? _activePlaylistId;
  void setActivePlaylistByName(String name) {
    _activePlaylistId = name;
    notifyListeners();
  }

  Future<void> start() async {
    await _playlistsSub?.cancel();
    _playlistsSub = _repo.streamVideoPlaylistsWithItems().listen((list) {
      _allPlaylists = list;

      // standard: nimm erste Playlist, wenn keine explizit gesetzt
      String? id = _activePlaylistId;
      if (id == null && list.isNotEmpty) {
        id = 'FIRST';
      }

      if (id != null) {
        if (id == 'FIRST' && list.isNotEmpty) {
          _playlist = list.first.playlistContent;
        } else {
          final found = list.firstWhere(
            (p) => p.playlistName == id,
            orElse: () => list.isNotEmpty
                ? list.first
                : VideoPlaylist(playlistName: '', playlistContent: []),
          );
          _playlist = found.playlistContent;
        }

        if (_currentVideoIndex != null && _playlist.isNotEmpty) {
          if (_currentVideoIndex! >= _playlist.length) {
            _currentVideoIndex = 0;
          }
        } else if (_playlist.isEmpty) {
          _currentVideoIndex = null;
        }
      } else {
        _playlist = [];
        _currentVideoIndex = null;
      }

      notifyListeners();
    }, onError: (e, st) {
      debugPrint('VideoPlaylistProvider stream error: $e');
    });
  }

  Future<void> stop() async {
    await _playlistsSub?.cancel();
    _playlistsSub = null;
  }

  // Steuerung (ohne Player-API, die habt ihr im Videoplayer)
  void playNext() {
    if (_currentVideoIndex != null && _playlist.isNotEmpty) {
      if (_currentVideoIndex! < _playlist.length - 1) {
        currentVideoIndex = _currentVideoIndex! + 1;
      } else {
        currentVideoIndex = 0;
      }
    }
  }

  void playPrevious() {
    if (_currentVideoIndex != null && _playlist.isNotEmpty) {
      if (_currentVideoIndex! > 0) {
        currentVideoIndex = _currentVideoIndex! - 1;
      } else {
        currentVideoIndex = _playlist.length - 1;
      }
    }
  }

  set currentVideoIndex(int? newIndex) {
    _currentVideoIndex = newIndex;
    notifyListeners();
  }

  @override
  void dispose() {
    _playlistsSub?.cancel();
    super.dispose();
  }
}
