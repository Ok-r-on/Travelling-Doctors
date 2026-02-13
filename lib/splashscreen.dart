import 'dart:async';

import 'package:flutter/material.dart';
import 'package:travelling_doctors/logandreg/choosing_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // Wait for 3 seconds and navigate to HomeScreen
    Timer(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChoosingPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/images/splashscreen.png', // Ensure this path matches your assets directory
            // This scales the image to cover the full screen
        ),
      ),
    );
  }
}