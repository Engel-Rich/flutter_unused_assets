import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Screen")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Image utilisée :", style: TextStyle(fontSize: 18)),
              Image.asset('assets/study1.png'),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/book.png'),
                  ),
                ),
              ),
              Image.asset('assets/study3.png'),
              Image.asset('assets/study2.png'),
              Image.asset('assets/study4.png'),
            ],
          ),
        ),
      ),
    );
  }
}

class AssetsImages {
  static const cours = "assets/book.png";
  static const insta = "assets/insta.png";
}
