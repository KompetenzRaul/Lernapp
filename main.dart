import 'package:flutter/material.dart';

import 'pages/createMusicPlaylist.dart';
import 'pages/createVideoPlaylist.dart';
import 'pages/homePage.dart';


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
      },
      initialRoute: '/',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xffe50043)),
      ),
    );
  }
}

