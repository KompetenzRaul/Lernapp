import 'package:flutter/foundation.dart';

class ErrorMarker {
  final String id;        // unique
  final String mediaId;   // z.B. Videopfad/ID
  final String title;     // kurzer Name
  final Duration position; // Zeitpunkt
  final DateTime createdAt;

  ErrorMarker({
    required this.id,
    required this.mediaId,
    required this.title,
    required this.position,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get mmss {
    final h = position.inHours;
    final m = position.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = position.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

/// Minimaler In-Memory-Store (ValueNotifier-basiert)
class ErrorMarkersStore {
  ErrorMarkersStore._();
  static final ErrorMarkersStore instance = ErrorMarkersStore._();

  final ValueNotifier<List<ErrorMarker>> list = ValueNotifier<List<ErrorMarker>>([]);

  void add({required String mediaId, required String title, required Duration position}) {
    final id = '${mediaId}_${DateTime.now().microsecondsSinceEpoch}';
    list.value = [
      ...list.value,
      ErrorMarker(id: id, mediaId: mediaId, title: title.trim(), position: position),
    ];
  }

  void remove(String id) {
    list.value = list.value.where((m) => m.id != id).toList();
  }

  void rename(String id, String newTitle) {
    list.value = list.value
        .map((m) => m.id == id ? ErrorMarker(id: m.id, mediaId: m.mediaId, title: newTitle.trim(), position: m.position, createdAt: m.createdAt) : m)
        .toList();
  }

  List<ErrorMarker> byMedia(String mediaId) =>
      list.value.where((m) => m.mediaId == mediaId).toList()
        ..sort((a, b) => a.position.compareTo(b.position));
}