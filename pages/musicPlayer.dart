import 'package:flutter/material.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  bool _playback_toggle = false;
  double _currentSliderValue = 50;

  @override
  Widget build(BuildContext context) {
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
                'assets/test_image.png',
                height: 300,
                width: 300,
                fit:  BoxFit.fill,
              ),
              // song name
              Text("Toxic - Britney Spears"),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //return
                  IconButton(
                    onPressed: () {
                      //go back to last song in playlist
                    },
                    icon: Icon(
                        Icons.skip_previous,
                        color: Color(0xffb70036),
                        size : 25.0
                    ),
                  ),
                  //pause / resume button
                  IconButton(
                    icon: _playback_toggle ? Icon(Icons.play_arrow) : Icon(Icons.pause),
                    color: Color(0xffb70036),

                    onPressed: () {
                      setState(() {
                        _playback_toggle = !_playback_toggle;
                      });
                    },
                  ),
                  //forward
                  IconButton(
                    onPressed: () {
                      //start next song in playlist
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
                value : _currentSliderValue,
                min: 0,
                max: 100,
                activeColor: Color(0xffb70036),
                onChanged: (double value) {
                  setState(() {
                    _currentSliderValue = value;
                  });
                },
              ),
              SizedBox(
                height: 250.00,
              )
            ]
        )
    );
  }
}
