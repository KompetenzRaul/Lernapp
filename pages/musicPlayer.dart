import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../datamodels/musicPlaylistProvider.dart';

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key, this.onFinished});

  final ValueChanged<double>?
  onFinished; // bleibt ungenutzt, da Provider global ist

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicPlaylistProvider>(
      builder: (context, value, child) {
        // Daten holen
        final playlist = value.playlist;

        // Guard: wenn noch keine Daten (erste Firestore-Antwort kommt gleich)
        if (playlist.isEmpty || value.currentSongIndex == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Aktuellen Song bestimmen (Index absichern)
        final safeIndex =
            (value.currentSongIndex! < playlist.length)
                ? value.currentSongIndex!
                : 0;
        final currentSong = playlist[safeIndex];

        // UI unverändert
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: const Color(0xffb70036),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            title: const Text(
              "Viducate",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 32,
                letterSpacing: 0.8,
              ),
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(height: 50.0),

              // album cover image
              Image.asset(
                currentSong.albumArtImagePath,
                height: 300,
                width: 300,
                fit: BoxFit.fill,
              ),

              // song name
              Text(currentSong.name),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // previous
                  IconButton(
                    onPressed: value.playPreviousSong,
                    icon: const Icon(
                      Icons.skip_previous,
                      color: Color(0xffb70036),
                      size: 25.0,
                    ),
                  ),
                  // pause / resume
                  IconButton(
                    icon:
                        value.isPlaying
                            ? const Icon(Icons.pause)
                            : const Icon(Icons.play_arrow),
                    color: const Color(0xffb70036),
                    onPressed: value.pauseOrResume,
                  ),
                  // next
                  IconButton(
                    onPressed: value.playNextSong,
                    icon: const Icon(
                      Icons.skip_next,
                      color: Color(0xffb70036),
                      size: 25.0,
                    ),
                  ),
                ],
              ),

              // duration slider
              Slider(
                min: 0,
                max: value.totalDuration.inSeconds.toDouble().clamp(
                  0,
                  double.infinity,
                ),
                value: value.currentDuration.inSeconds.toDouble().clamp(
                  0,
                  value.totalDuration.inSeconds.toDouble(),
                ),
                activeColor: const Color(0xffb70036),
                onChanged: (_) {
                  // optional: live seeking erst bei onChangeEnd
                },
                onChangeEnd: (pos) {
                  value.seek(Duration(seconds: pos.toInt()));
                },
              ),

              const SizedBox(height: 250.0),
            ],
          ),
        );
      },
    );
  }
}
