import 'package:flutter/services.dart';

class OpenDocumentService {
  static const MethodChannel _channel = MethodChannel('app.open_document');

  /// Öffnet den Android Systempicker (ACTION_OPEN_DOCUMENT) für mehrere Videos
  /// und liefert eine Liste von Maps: {uri, name, size}.
  static Future<List<PickedVideo>> pickVideos() async {
    final raw = await _channel.invokeMethod<List<dynamic>>('pickVideos');
    final list = raw ?? const [];
    return list.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return PickedVideo(
        uri: m['uri'] as String,
        name: (m['name'] ?? 'Video').toString(),
        size: (m['size'] is int) ? m['size'] as int : -1,
      );
    }).toList();
  }
}

class PickedVideo {
  final String uri; // content:// URI
  final String name;
  final int size; // -1 falls unbekannt
  const PickedVideo({required this.uri, required this.name, required this.size});
}
