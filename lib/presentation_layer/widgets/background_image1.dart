import 'package:flutter/material.dart';

class BackgroundImage1 extends StatelessWidget {
  const BackgroundImage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.6,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            'images/p2.png', // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
