import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// Deine Models
import '../datamodels/musicElement.dart';
import '../datamodels/musicPlaylist.dart';

// Firestore-Repo
import '../repository/firestore_repository.dart';

class MusicPlaylistProvider extends ChangeNotifier {
  MusicPlaylistProvider(this._repo, {ValueChanged<double>? onFinished}) {
    _onFinished = onFinished;
    // Configure player
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    // Audio-Events abonnieren (wie zuvor)
    _durationSubscription = _audioPlayer.onDurationChanged.listen((
      newDuration,
    ) {
      _totalDuration = newDuration;
      notifyListeners();
    });
    _positionSubscription = _audioPlayer.onPositionChanged.listen((
      newPosition,
    ) {
      _currentDuration = newPosition;
      notifyListeners();
    });
    _completionSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      final played = _totalDuration.inSeconds.toDouble();
      final cb = _onFinished;
      if (cb != null) cb(played);
    });
  }

  final FirestoreRepository _repo;
  ValueChanged<double>? _onFinished;

  void setOnFinished(ValueChanged<double>? cb) {
    _onFinished = cb;
  }

  // ---- CRUD-API für CreateMusicPlaylistPage ----
  Future<String> createPlaylist(String name) async {
    final id = await _repo.createMusicPlaylist(name);
    return id;
  }

  Future<String> addToPlaylist({
    required String playlistId,
    required MusicElement item,
    int? order,
  }) {
    return _repo.addMusicItem(playlistId, item, order: order);
  }

  Future<void> removeFromPlaylist({
    required String playlistId,
    required String itemId,
  }) {
    return _repo.removeMusicItem(playlistId, itemId);
  }

  Future<void> deletePlaylist(String playlistId) {
    return _repo.deleteMusicPlaylist(playlistId);
  }

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
    _playlistsSub = _repo.streamMusicPlaylistsWithItems().listen(
      (list) {
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
              (p) =>
                  p.playlistName == id, // falls du später mit Namen selektierst
              orElse:
                  () =>
                      list.isNotEmpty
                          ? list.first
                          : MusicPlaylist(
                            playlistName: '',
                            playlistContent: [],
                          ),
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
      },
      onError: (e, st) {
        debugPrint('MusicPlaylistProvider stream error: $e');
      },
    );
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

  // Track whether a source has been loaded at least once for the current index
  bool _hasSourceLoaded = false;

  // play the song
  Future<void> play() async {
    if (_currentSongIndex == null || _playlist.isEmpty) return;

    final String path = _playlist[_currentSongIndex!].filePath;
    debugPrint('Audio play(): index=$_currentSongIndex path=$path');

    await _audioPlayer.stop();
  // Use proper source: treat absolute/local paths as device files, not assets.
  // Also fix cases where a device path was accidentally saved with an 'assets/' prefix.
    final String fixedPath = _ensureCorrectDevicePath(path);
    Source src;
    if (_isLikelyAsset(fixedPath)) {
      debugPrint('Audio source -> ASSET ${_normalizeAssetPath(fixedPath)}');
      src = AssetSource(_normalizeAssetPath(fixedPath));
    } else {
      final devicePath = _asDevicePath(fixedPath);
      if (!File(devicePath).existsSync()) {
        debugPrint('Music file not found: $devicePath');
        _isPlaying = false;
        _hasSourceLoaded = false;
        notifyListeners();
        return;
      }
      debugPrint('Audio source -> FILE $devicePath');
      src = DeviceFileSource(devicePath);
    }
    try {
      await _audioPlayer.play(src);
    } catch (e, st) {
      debugPrint('Audio play() failed: $e');
      debugPrintStack(stackTrace: st);
      _isPlaying = false;
      _hasSourceLoaded = false;
      notifyListeners();
      return;
    }
    _isPlaying = true;
    _hasSourceLoaded = true;
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
      debugPrint('Audio pause requested');
      pause();
    } else {
      // If we never loaded a source for the current index, start playing
      if (!_hasSourceLoaded) {
        debugPrint('Audio resume button pressed, no source loaded -> play()');
        play();
      } else {
        // Just resume; do not reset the index which would trigger a fresh play()
        debugPrint('Audio resume requested');
        resume();
      }
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

  // ---------------------------
  // Helpers
  // ---------------------------
  // Heuristic: a path is an asset if it starts with 'assets/' AND the remainder
  // does not look like an absolute device path (Android/iOS/Windows).
  bool _isLikelyAsset(String originalPath) {
    final String p = originalPath.replaceAll('\\', '/');
    if (!p.startsWith('assets/')) return false;
    final String rest = p.substring('assets/'.length);
    if (rest.isEmpty) return true;
    final String r = rest.startsWith('/') ? rest.substring(1) : rest;
    final bool looksAndroidAbs = r.startsWith('data/') || r.startsWith('storage/') || r.startsWith('sdcard/') || r.startsWith('mnt/');
    final bool looksIOSAbs = r.startsWith('var/') || r.startsWith('private/var/');
    final bool looksWindowsAbs = r.contains(':/'); // e.g., C:/path
    return !(looksAndroidAbs || looksIOSAbs || looksWindowsAbs);
  }

  // Normalize asset keys and collapse duplicate slashes after 'assets/'.
  String _normalizeAssetPath(String originalPath) {
    String p = originalPath.replaceAll('\\', '/');
    if (!p.startsWith('assets/')) return p;
    // Collapse multiple slashes after 'assets/'
    p = p.replaceFirst(RegExp(r'^assets/+'), 'assets/');
    return p;
  }

  // If a device path was accidentally saved with an 'assets/' prefix, strip it.
  String _asDevicePath(String originalPath) {
    String p = originalPath.replaceAll('\\', '/');
    if (p.startsWith('assets/')) {
      p = p.replaceFirst(RegExp(r'^assets/+'), '');
    }
    return p;
  }

  // Convenience: for any incoming path, correct obvious mistakes where an absolute
  // path was prefixed with 'assets/'. Otherwise return unchanged.
  String _ensureCorrectDevicePath(String originalPath) {
    final String p = originalPath.replaceAll('\\', '/');
    if (!p.startsWith('assets/')) return originalPath;
    final String rest = p.substring('assets/'.length);
    final String r = rest.startsWith('/') ? rest.substring(1) : rest;
    final bool looksAndroidAbs = r.startsWith('data/') || r.startsWith('storage/') || r.startsWith('sdcard/') || r.startsWith('mnt/');
    final bool looksIOSAbs = r.startsWith('var/') || r.startsWith('private/var/');
    final bool looksWindowsAbs = r.contains(':/');
    if (looksAndroidAbs || looksIOSAbs || looksWindowsAbs) {
      // Strip the mistaken 'assets/' prefix
      return r;
    }
    return originalPath;
  }
}
