import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _videoController = PageController(
    viewportFraction: 0.85,
  );
  final PageController _musicController = PageController(
    viewportFraction: 0.85,
  );
  double _sliderValue = 0.5;

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
              icon: const Icon(Icons.add, size: 16, color: Color(0xff425159)),
              label: const Text(
                "Auswählen",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff425159),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xff425159), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Viducate')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Playlists
            _buildSectionTitle("Video Playlists"),
            _buildPlaylistSection(_videoController, 6, "Astronomie"),
            const SizedBox(height: 24),
            // Music Playlists
            _buildSectionTitle("Music Playlists"),
            _buildPlaylistSection(
              _musicController,
              2,
              "Üppings Lieblings Musik",
            ),
            const SizedBox(height: 24),
            // Regler
            Text(
              "Verhältnis Video/Musik",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                Slider(
                  value: _sliderValue,
                  min: 0,
                  max: 1,
                  divisions: 20,
                  activeColor: const Color(0xffb70036),
                  inactiveColor: Colors.grey.shade300,
                  label: "${(_sliderValue * 100).round()}% Video",
                  onChanged: (value) {
                    setState(() {
                      _sliderValue = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${(_sliderValue * 100).round()}% Video"),
                    Text("${(100 - _sliderValue * 100).round()}% Musik"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Abspielen Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Hier Funktion zum Abspielen
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text("Abspielen"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffb70036),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 25,
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistSection(
    PageController controller,
    int itemCount,
    String title,
  ) {
    return Column(
      children: [
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xffb70036),
            borderRadius: BorderRadius.circular(16),
          ),
          child: PageView.builder(
            controller: controller,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 12.0,
                ),
                child: _buildPlaylistCard("$title ${index + 1}"),
              );
            },
          ),
        ),
        const SizedBox(),
        Padding(
          padding: const EdgeInsets.only(),
          child: Center(
            child: SmoothPageIndicator(
              controller: controller,
              count: itemCount,
              effect: WormEffect(
                dotHeight: 10,
                dotWidth: 10,
                activeDotColor: const Color(0xffb70036),
                dotColor: Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
