import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart'; // import navigatorKey

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 2), () {
      navigatorKey.currentState?.pushReplacementNamed('/welcome');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.6,
            ),
            child: const Image(
              image: AssetImage('assets/images/neyyar_logo.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
