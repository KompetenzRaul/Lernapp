import 'package:flutter/material.dart';

import '../datamodels/dummyData.dart';
import '../datamodels/videoPlaylist.dart';

class CreateVideoPlaylistPage extends StatefulWidget {
  const CreateVideoPlaylistPage({super.key});

  @override
  State<CreateVideoPlaylistPage> createState() => _CreateVideoPlaylistPageState();
}

class _CreateVideoPlaylistPageState extends State<CreateVideoPlaylistPage> {

  VideoPlaylist _dummyData = DummyData.dummyDataVideo;

  void _showRenameDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Name der Playlist"),
            content: TextField(
              maxLength: 20,
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Abbrechen"),
                style: ButtonStyle(


                ),
              ),

              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Speichern"),
              )
            ],
          );
        }
    );
  }

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
          title: Text(
            "Viducate",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 32,
                letterSpacing: 0.8
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Video Playlist erstellen",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Color(0xff425159)
                ),
              ),

              SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        _dummyData.playlistName,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                            color: Color(0xff425159)
                        ),
                      ),

                      SizedBox(width: 5),

                      IconButton(
                        onPressed: () {
                          _showRenameDialog(context);
                        },
                        icon: Icon(
                          Icons.edit,
                        ),
                      ),
                    ],
                  ),

                  FloatingActionButton.extended(
                    onPressed: () {},
                    extendedIconLabelSpacing: 10,
                    extendedPadding: EdgeInsets.symmetric(horizontal: 20),
                    label: Text("Dateien öffnen", style: TextStyle(fontSize: 15, letterSpacing: 0.5),),
                    icon: Icon(Icons.upload),
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xffb70036),
                    elevation: 2.5,
                  )
                ],
              ),
              SizedBox(height: 10,),

              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView.separated(
                    scrollDirection: Axis.vertical,
                    itemCount: _dummyData.playlistContent.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(color: Color(0xff425159));
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return _dummyData.playlistContent[index].toListTile();
                    },

                  )
                ),
              ),
              SizedBox(height: 20,),

              Center(
                child: FloatingActionButton.extended(
                  onPressed: () {},
                  extendedPadding: EdgeInsets.symmetric(horizontal: 120),
                  label: Text("Erstellen", style: TextStyle(fontSize: 15, letterSpacing: 0.5),),
                  icon: Icon(Icons.check),
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xffb70036),
                  elevation: 2.5,
                ),
              )
            ],
          ),
        ) //
    );
  }
}
