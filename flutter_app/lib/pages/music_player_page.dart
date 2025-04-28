import "package:flutter/material.dart";

class MusicPlayerPage extends StatelessWidget {
  const MusicPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true, 
        title: const Text("Viducate"),
        leading: IconButton(
          onPressed: () {
            //go back to home page
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size : 25.0
          ),
        ),
        ),
        body: Center(
          child : Image.asset(
            'assets/test_image.png'
            ),
        )
    );
  }
}