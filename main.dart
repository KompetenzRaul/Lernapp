import 'package:flutter/material.dart';

import 'pages/createMusicPlaylist.dart';
import 'pages/createVideoPlaylist.dart';


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
        '/': (context) => MyHomePage(title: "Viducate"),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true
      ),
      body: Column(
        children: [
          FilledButton(
            onPressed: () {
              Navigator.pushNamed(context, '/createMusicPlaylist');
            },
            child: Text("Musik"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pushNamed(context, '/createVideoPlaylist');
            },
            child: Text("Videos"),
          )
        ],
      ),
    );
  }
}