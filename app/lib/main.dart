import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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

Widget _buildPlaylistCard(String name) {
  return Container(
    width: 100,
    height: 180,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(name, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.add,
              size: 16,
              color: Color(0xFF6C6C6C), // graues Icon
            ),
            label: const Text(
              "Auswählen",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6C6C6C), // grauer Text
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Color(0xFF6C6C6C), // grauer Rahmen
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // pillenförmig
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ],
    ),
  );
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _videoController = PageController(viewportFraction: 0.85);
  final PageController _musicController = PageController(viewportFraction: 0.85);

  

 

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
                        color: Colors.grey,
                        shape: BoxShape.circle,
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
                  child: PageView.builder(
                    controller: _videoController,
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 12.0,
                        ),
                        child: _buildPlaylistCard("Astronomie ${index + 1}"),
                      );
                    },
                  ),
                ),
                const SizedBox(),
                Padding(
                  padding: const EdgeInsets.only(),
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: _videoController,
                      count: 6,
                      effect: WormEffect(
                        dotHeight: 10,
                        dotWidth: 10,
                        activeDotColor: Color(0xFFB3001B),
                        dotColor: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "Music Playlists",
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
                        color: Colors.grey,
                        shape: BoxShape.circle,
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
                // 3. Musik Playlists Titel + Button
                Container(
                  height: 200,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0x80B3001B), // transparentes Rot
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: PageView.builder(
                    controller: _musicController,
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 12.0,
                        ),
                        child: _buildPlaylistCard("Üppings Lieblings Musik ${index + 1}"),
                      );
                    },
                  ),
                ),
                // 4. Musik Kachel
                const SizedBox(),
                Padding(
                  padding: const EdgeInsets.only(),
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: _musicController,
                      count: 2,
                      effect: WormEffect(
                        dotHeight: 10,
                        dotWidth: 10,
                        activeDotColor: Color(0xFFB3001B),
                        dotColor: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 5. Regler mit Verhältnis
            // 6. Abspielen-Button
          ],
        ),
      ),
    );
  }
}
