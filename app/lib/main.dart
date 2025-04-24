import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ViduCate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFB3001B)),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(fontSize: 30),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0)),
          ),
          backgroundColor: Color(0xFFB3001B),
          foregroundColor: Colors.white,
        ),
      ),

      home: const MyHomePage(title: 'Viducate'),
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
      appBar: AppBar(centerTitle: true, title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Video Playlists Titel + Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "Video Playlists",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey, // Hintergrundfarbe
                        shape: BoxShape.circle, // macht ihn rund
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 25,
                        onPressed: () {},
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white, // Farbe des Plus-Zeichens
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 2. Video-Kachel
            // 3. Musik Playlists Titel + Button
            // 4. Musik-Kachel
            // 5. Regler mit Verhältnis
            // 6. Abspielen-Button
          ],
        ),
      ),
    );
  }
}
