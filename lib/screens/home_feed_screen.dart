// home_feed_screen.dart
import 'package:flutter/material.dart';

/// The main landing screen displaying the feed for the food posts.
/// Assigned to: Aguiluz
/// TODO: Add a Search Bar widget at the top and a ListView to display available items later on (need for milestone 1 to)
class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        // Centered placeholder text for the main feed view
        child: Text(
          'Home Feed ni Aguiluz (Search Bar Dito)',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}