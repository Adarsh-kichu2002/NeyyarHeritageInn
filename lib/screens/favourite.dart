import 'package:flutter/material.dart';

class Favourite extends StatelessWidget {
  const Favourite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite'),
      ),
      body: const Center(
        child: Text(
          'This is the Favourite Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}