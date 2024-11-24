import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.blue.shade800,
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.6,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                'images/p1.png', // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
