import 'package:cloud_firestore/cloud_firestore.dart';
import '../datamodels/musicElement.dart';
import '../datamodels/videoElement.dart';
import '../datamodels/musicPlaylist.dart';
import '../datamodels/videoPlaylist.dart';

class FirestoreRepository {
  FirestoreRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // Collection-Namen zentral
  static const String _musicPlaylistsCol = 'musicPlaylists';
  static const String _videoPlaylistsCol = 'videoPlaylists';
  static const String _itemsSubCol = 'items';

  // ---------------------------
  // Music: Playlists
  // ---------------------------

  Stream<List<MusicPlaylist>> streamMusicPlaylists() {
    return _db
        .collection(_musicPlaylistsCol)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snap) async {
          final playlists = <MusicPlaylist>[];
          for (final doc in snap.docs) {
            final data = doc.data();
            final playlist = MusicPlaylist.fromMap(data, []);
            playlists.add(playlist);
          }
          return playlists;
        });
  }

  /// Playlists inkl. deren Items streamen
  Stream<List<MusicPlaylist>> streamMusicPlaylistsWithItems() {
    return _db
        .collection(_musicPlaylistsCol)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snap) async {
          final result = <MusicPlaylist>[];
          for (final doc in snap.docs) {
            final items =
                await _db
                    .collection(_musicPlaylistsCol)
                    .doc(doc.id)
                    .collection(_itemsSubCol)
                    .orderBy('createdAt', descending: false)
                    .get();

            final musicItems =
                items.docs.map((d) {
                  final m = d.data();
                  return MusicElement.fromMap(m);
                }).toList();

            final playlist = MusicPlaylist.fromMap(doc.data(), musicItems);
            result.add(playlist);
          }
          return result;
        });
  }

  Future<String> createMusicPlaylist(String name) async {
    final ref = await _db.collection(_musicPlaylistsCol).add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
    
  }

  Future<void> deleteMusicPlaylist(String playlistId) async {
    final batch = _db.batch();
    final itemsRef = _db
        .collection(_musicPlaylistsCol)
        .doc(playlistId)
        .collection(_itemsSubCol);

    final items = await itemsRef.get();
    for (final d in items.docs) {
      batch.delete(d.reference);
    }
    batch.delete(_db.collection(_musicPlaylistsCol).doc(playlistId));
    await batch.commit();
  }

  // ---------------------------
  // Music: Items
  // ---------------------------

  Stream<List<MusicElement>> streamMusicItems(String playlistId) {
    return _db
        .collection(_musicPlaylistsCol)
        .doc(playlistId)
        .collection(_itemsSubCol)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => MusicElement.fromMap(d.data())).toList(),
        );
  }

  Future<String> addMusicItem(
    String playlistId,
    MusicElement item, {
    int? order,
  }) async {
    final data = item.toMap();
    data['order'] = order ?? 0;
    data['createdAt'] = FieldValue.serverTimestamp();
    final ref = await _db
        .collection(_musicPlaylistsCol)
        .doc(playlistId)
        .collection(_itemsSubCol)
        .add(data);
    return ref.id;
  }

  Future<void> removeMusicItem(String playlistId, String itemId) async {
    await _db
        .collection(_musicPlaylistsCol)
        .doc(playlistId)
        .collection(_itemsSubCol)
        .doc(itemId)
        .delete();
  }

  // ---------------------------
  // Video: Playlists
  // ---------------------------

  Stream<List<VideoPlaylist>> streamVideoPlaylists() {
    return _db
        .collection(_videoPlaylistsCol)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snap) async {
          final playlists = <VideoPlaylist>[];
          for (final doc in snap.docs) {
            final playlist = VideoPlaylist.fromMap(doc.data(), []);
            playlists.add(playlist);
          }
          return playlists;
        });
  }

  Stream<List<VideoPlaylist>> streamVideoPlaylistsWithItems() {
    return _db
        .collection(_videoPlaylistsCol)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snap) async {
          final result = <VideoPlaylist>[];
          for (final doc in snap.docs) {
            final items =
                await _db
                    .collection(_videoPlaylistsCol)
                    .doc(doc.id)
                    .collection(_itemsSubCol)
                    .orderBy('createdAt', descending: false)
                    .get();

            final videoItems =
                items.docs.map((d) {
                  final m = d.data();
                  return VideoElement.fromMap(m);
                }).toList();

            final playlist = VideoPlaylist.fromMap(doc.data(), videoItems);
            result.add(playlist);
          }
          return result;
        });
  }

  Future<String> createVideoPlaylist(String name) async {
    final ref = await _db.collection(_videoPlaylistsCol).add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> deleteVideoPlaylist(String playlistId) async {
    final batch = _db.batch();
    final itemsRef = _db
        .collection(_videoPlaylistsCol)
        .doc(playlistId)
        .collection(_itemsSubCol);

    final items = await itemsRef.get();
    for (final d in items.docs) {
      batch.delete(d.reference);
    }
    batch.delete(_db.collection(_videoPlaylistsCol).doc(playlistId));
    await batch.commit();
  }

  // ---------------------------
  // Video: Items
  // ---------------------------

  Stream<List<VideoElement>> streamVideoItems(String playlistId) {
    return _db
        .collection(_videoPlaylistsCol)
        .doc(playlistId)
        .collection(_itemsSubCol)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => VideoElement.fromMap(d.data())).toList(),
        );
  }

  Future<String> addVideoItem(
    String playlistId,
    VideoElement item, {
    int? order,
  }) async {
    final data = item.toMap();
    data['order'] = order ?? 0;
    data['createdAt'] = FieldValue.serverTimestamp();
    final ref = await _db
        .collection(_videoPlaylistsCol)
        .doc(playlistId)
        .collection(_itemsSubCol)
        .add(data);
    return ref.id;
  }

  Future<void> removeVideoItem(String playlistId, String itemId) async {
    await _db
        .collection(_videoPlaylistsCol)
        .doc(playlistId)
        .collection(_itemsSubCol)
        .doc(itemId)
        .delete();
  }
}
