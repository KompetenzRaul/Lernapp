import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:metadata_god/metadata_god.dart';

import 'pages/createMusicPlaylist.dart';
import 'pages/createVideoPlaylist.dart';
import 'pages/homePage.dart';
import 'pages/musicPlayer.dart';
import 'pages/videoPlayer.dart';

import './repository/firestore_repository.dart';
import './datamodels/musicPlaylistProvider.dart';
import './datamodels/videoPlaylistProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Firebase zuerst
  await Firebase.initializeApp();

  // 2) App starten
  runApp(const MyApp());

  // 3) MetadataGod später/lazy
  _initMetadata();
}

Future<void> _initMetadata() async {
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      await MetadataGod.initialize();
      debugPrint('MetadataGod initialized ✅');
    }
  } catch (e, st) {
    debugPrint('MetadataGod init error: $e');
    debugPrintStack(stackTrace: st);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FirestoreRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MusicPlaylistProvider>(
          create: (_) {
            final p = MusicPlaylistProvider(repo);
            p.start();
            return p;
          },
        ),
        ChangeNotifierProvider<VideoPlaylistProvider>(
          create: (_) {
            final p = VideoPlaylistProvider(repo);
            p.start();
            return p;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => const Homepage(),
          '/createMusicPlaylist': (context) => const CreateMusicPlaylistPage(),
          '/createVideoPlaylist': (context) => const CreateVideoPlaylistPage(),
          '/musicPlayer': (context) => const MusicPlayer(),
          // Für /videoPlayer holen wir den Pfad aus arguments:
          '/videoPlayer': (context) {
            final path = ModalRoute.of(context)!.settings.arguments as String;
            return Videoplayer(videoPath: path);
          },
        },
        initialRoute: '/',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xffb70036),
            primary: const Color(0xffb70036),
          ),
        ),
      ),
    );
  }
}
