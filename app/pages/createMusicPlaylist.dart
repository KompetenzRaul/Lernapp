import 'package:flutter/material.dart';


class CreateMusicPlaylistPage extends StatelessWidget {
  const CreateMusicPlaylistPage({super.key});

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
                "Musik Playlist erstellen",
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
                        "Musik 1",
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
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    children: [
                      ListTile( //#1
                        title: Text(
                          "Never gonna give you up",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff425159),
                              letterSpacing: 0.6
                          ),
                        ),
                        trailing: Icon(Icons.arrow_right),
                        iconColor: Color(0xff425159),
                        subtitle: Text("Rick Astley"),
                      ),
                      Divider(height: 2),

                      ListTile( //#2
                        title: Text(
                          "Sandstorm",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff425159),
                              letterSpacing: 0.6
                          ),
                        ),
                        trailing: Icon(Icons.arrow_right),
                        iconColor: Color(0xff425159),
                        subtitle: Text("Darude"),
                      ),
                      Divider(height: 2),

                      ListTile( //#3
                        title: Text(
                          "Everytime we touch",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff425159),
                              letterSpacing: 0.6
                          ),
                        ),
                        trailing: Icon(Icons.arrow_right),
                        iconColor: Color(0xff425159),
                        subtitle: Text("Cascada"),
                      ),
                      Divider(height: 2),

                      ListTile( //#4
                        title: Text(
                          "Cotton Eye Joe",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff425159),
                              letterSpacing: 0.6
                          ),
                        ),
                        trailing: Icon(Icons.arrow_right),
                        iconColor: Color(0xff425159),
                        subtitle: Text("Rednex"),
                      ),
                      Divider(height: 2),


                    ],
                  ),
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