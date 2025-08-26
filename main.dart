import 'package:flutter/material.dart';


import 'pages/createMusicPlaylist.dart';
import 'pages/createVideoPlaylist.dart';
import 'pages/homePage.dart';
import 'pages/musicPlayer.dart';
import 'pages/videoPlayer.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => Homepage(),
        '/createMusicPlaylist': (context) => CreateMusicPlaylistPage(),
        '/createVideoPlaylist': (context) => CreateVideoPlaylistPage(),
        '/videoPlayer': (context) => Videoplayer(),
        '/musicPlayer': (context) => MusicPlayer()
      },
      initialRoute: '/',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xffb70036), primary: Color(0xffb70036)),
      ),
    );
  }
}

