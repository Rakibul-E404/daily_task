import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'splash_screen_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final SplashScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SplashScreenController(splashDuration: 4);
    _controller.startTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/images/logo.svg',
              width: 200,
              height: 200,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 50),
              child: SvgPicture.asset(
                'assets/images/splash_screen_top_shade.svg',
                width: 100,
                height: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
