import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 50, // Header
            child: Placeholder(),
          ),
          Expanded(
            child: Placeholder(), // Content
          ),
          SizedBox(
            height: 50, // Footer
            child: Placeholder(),
          ),
        ],
      ),
    );
  }
}