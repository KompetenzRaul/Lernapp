import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';



class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  String? _selectedVideoPlaylist;
  String? _selectedMusicPlaylist;

  final PageController _videoController = PageController(
    viewportFraction: 0.65,
  );
  final PageController _musicController = PageController(
    viewportFraction: 0.65,
  );
  double _sliderValue = 0.5;

  Widget _buildPlaylistCard(String name, {required bool isVideo}) {
    final bool isSelected =
    isVideo
        ? _selectedVideoPlaylist == name
        : _selectedMusicPlaylist == name;

    return Container(
      width: 100,
      height: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  if (isVideo) {
                    if (_selectedVideoPlaylist == name) {
                      _selectedVideoPlaylist = null;
                    } else {
                      _selectedVideoPlaylist = name;
                    }
                  } else {
                    if (_selectedMusicPlaylist == name) {
                      _selectedMusicPlaylist = null;
                    } else {
                      _selectedMusicPlaylist = name;
                    }
                  }
                });
              },
              icon: Icon(
                isSelected ? Icons.check : Icons.add,
                size: 16,
                color: isSelected ? Colors.white : Color(0xff425159),
              ),
              label: Text(
                isSelected ? "Gewählt" : "Auswählen",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Color(0xff425159),
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor:
                isSelected ? const Color(0xffb70036) : Colors.transparent,
                side: BorderSide(
                  color:
                  isSelected
                      ? const Color(0xffb70036)
                      : const Color(0xff425159),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: const Color(0xffb70036)),
              child: Text(
                'Menü',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Einstellungen'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Info'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
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
      ), backgroundColor: Color(0xffb70036),),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Video Playlists", "/createVideoPlaylist"), //ich hab da noch den Route String übergeben, weil wir ja auf zwei unterschiedliche Seiten wollen.
            _buildPlaylistSection(                                         //einmal auf die VideoPlaylist-Seite und einmal auf die MusikPlaylist-Seite... - Till
              _videoController,
              6,
              "Astronomie",
              isVideo: true,
              height: 160,
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("Music Playlists", "/createMusicPlaylist"), //hier das gleiche
            _buildPlaylistSection(
              _musicController,
              2,
              "Üppings Lieblings Musik",
              isVideo: false,
              height: 160,
            ),
            const SizedBox(height: 16),
            Text(
              "Verhältnis Video/Musik",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed("/videoPlayer");
                },
                onLongPress: () {
                  Navigator.of(context).pushNamed("/musicPlayer");
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

  Widget _buildSectionTitle(String title, String routeToPushTo) {
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
            onPressed: () {
              Navigator.of(context).pushNamed(routeToPushTo);
            },
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistSection(
      PageController controller,
      int itemCount,
      String title, {
        required bool isVideo,
        required double height,
      }) {
    return Column(
      children: [
        Container(
          height: height,
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
                child: _buildPlaylistCard(
                  "$title ${index + 1}",
                  isVideo: isVideo,
                ),
              );
            },
          ),
        ),
        Center(
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
      ],
    );
  }
}

