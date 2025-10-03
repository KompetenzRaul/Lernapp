import 'package:flutter/material.dart';
import '../datamodels/error_markers.dart';

class ErrorMarkersPage extends StatelessWidget {
  final String? mediaId; // wenn gesetzt: nur Marker für dieses Medium
  final bool tapToPopWithResult; // bei true: Tap gibt den Marker zurück

  const ErrorMarkersPage({super.key, this.mediaId, this.tapToPopWithResult = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fehlerliste')),
      body: ValueListenableBuilder<List<ErrorMarker>>(
        valueListenable: ErrorMarkersStore.instance.list,
        builder: (context, list, _) {
          List<ErrorMarker> data = mediaId == null
              ? List.of(list)
              : ErrorMarkersStore.instance.byMedia(mediaId!);

          if (data.isEmpty) return const _EmptyState();

          data.sort((a, b) => a.position.compareTo(b.position));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final m = data[i];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${m.mmss}  •  ${m.mediaId}'),
                  trailing: IconButton(
                    tooltip: 'Löschen',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => ErrorMarkersStore.instance.remove(m.id),
                  ),
                  onTap: () {
                    if (tapToPopWithResult) Navigator.of(context).pop(m);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.flag_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('Noch keine Fehler markiert', style: TextStyle(fontSize: 18)),
          SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Im Player auf den Markieren-Button tippen, um die erste Marke zu setzen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}