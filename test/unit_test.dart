
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animated_text_kit/animated_text_kit.dart';  // If relevant
import 'package:dream_interpret/presentation_layer/screens/splash_screen.dart'; // Assuming SplashScreen is in the same directory

void main() {
  testWidgets('Splash screen renders image and text widgets on creation', (WidgetTester tester) async {
    // Create the widget within a MaterialApp
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    // Find widgets
    final image = find.byType(Image); // Update if needed (e.g., AnimatedTextKit)
    final textKit = find.byType(AnimatedTextKit); // Update if needed

    // Assert presence
    expect(image, findsOneWidget);
    expect(textKit, findsOneWidget); // Update if needed
  });
}