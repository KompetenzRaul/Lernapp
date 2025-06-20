import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../datamodels/musicPlaylistProvider.dart';

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key, this.onFinished});

  final ValueChanged<double>? onFinished;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MusicPlaylistProvider(onFinished: onFinished),
      child : Consumer<MusicPlaylistProvider>(
      builder: (context, value, child) {

        // get playlist
        final playlist = value.playlist;

        //get current song index
        final currentSong = playlist[value.currentSongIndex ?? 0];

        //return Scaffold UI
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Color(0xffb70036),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)
                )
            ),
            title: const Text(
              "Viducate",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 32,
                  letterSpacing: 0.8
              ),
            ),

          ),
          body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                SizedBox(height: 50.0,),

                // album cover image
                Image.asset(
                  currentSong.albumArtImagePath,
                  height: 300,
                  width: 300,
                  fit:  BoxFit.fill,
                ),

                // song name
                Text(currentSong.artistName),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //return
                    IconButton(
                      onPressed: () {
                        //go back to last song in playlist
                        value.playPreviousSong();
                      },
                      icon: Icon(
                          Icons.skip_previous,
                          color: Color(0xffb70036),
                          size : 25.0
                      ),
                    ),
                    //pause / resume button
                    IconButton(
                      icon: value.isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                      color: Color(0xffb70036),
                      onPressed: () {
                        value.pauseOrResume();
                      },
                    ),
                    //forward
                    IconButton(
                      onPressed: () {
                        //start next song in playlist
                        value.playNextSong();
                      },
                      icon: Icon(
                          Icons.skip_next,
                          color: Color(0xffb70036),
                          size : 25.0
                      ),
                    ),
                  ],
                ),
                // song duration slider
                Slider(
                  min: 0,
                  max: value.totalDuration.inSeconds.toDouble(),
                  value : value.currentDuration.inSeconds.toDouble(),
                  activeColor: Color(0xffb70036),
                  onChanged: (double double) {
                    // during when the user is sliding around
                  },
                  onChangeEnd: (double double) {
                    //sliding has finished, go to that position in song duration 
                    value.seek(Duration(seconds: double.toInt()));
                  },
                ),
                SizedBox(
                  height: 250.00,
                )
              ]
          )
        );
      }
    )
    );
  }
}
