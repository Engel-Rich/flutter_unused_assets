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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Image utilisée :", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Image.asset('assets/study1.png'),
              const SizedBox(height: 10),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/study5.png'),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Image.asset('assets/study3.png'),
              const SizedBox(height: 10),
              Image.asset('assets/study4.png'),
            ],
          ),
        ),
      ),
    );
  }
}
