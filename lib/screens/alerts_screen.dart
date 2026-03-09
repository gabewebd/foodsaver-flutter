// alerts_screen.dart
import 'package:flutter/material.dart';

/// Displays notifications and updates for the user.
/// Assigned to: Yamaguchi
/// Note: Needs to fetch alert data and handle read/unread state logic (later on muna)
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // provides the basic material design visual layout structure
    return const Scaffold(
      body: Center(
        // Centered placeholder for the upcoming alerts list
        child: Text(
          'Alerts/Hub (Yamaguchi Logic Here)',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}