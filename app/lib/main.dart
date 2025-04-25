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

Widget _buildPlaylistPage(int pageIndex) {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        return _buildPlaylistCard(
          "Astronomie ${(pageIndex - 1) * 3 + index + 1}",
        );
      }),
    ),
  );
}

Widget _buildPlaylistCard(String name) {
  return Container(
    width: 100,
    height: 140,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.grey,
              textStyle: const TextStyle(fontSize: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {},
            child: const Text("Auswählen"),
          ),
        ),
      ],
    ),
  );
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
                // 2. Video-Kachel
                Container(
                  height: 200,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0x80B3001B), // transparentes Rot
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: PageView(
                    children: [_buildPlaylistPage(1), _buildPlaylistPage(2)],
                  ),
                ),
              ],
            ),
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
