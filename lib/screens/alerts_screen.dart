import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum _AlertType { claim, nearby, follower, expiry }

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildAlertCard(
                  type: _AlertType.claim,
                  title: 'Item Claimed!',
                  description: 'Aguiluz claimed your "Pasta Sauce"',
                  time: '2 min ago',
                  isNew: true,
                  hasActions: true,
                ),
                _buildAlertCard(
                  type: _AlertType.nearby,
                  title: 'New Item Nearby',
                  description: 'Fresh bread available in Building C',
                  time: '15 min ago',
                  isNew: true,
                ),
                _buildAlertCard(
                  type: _AlertType.follower,
                  title: 'New Follower',
                  description: 'John started following your posts',
                  time: '1 hour ago',
                ),
                _buildAlertCard(
                  type: _AlertType.expiry,
                  title: 'Expiry Alert',
                  description: 'Your yogurt expires in 2 days',
                  time: '3 hours ago',
                ),
                _buildAlertCard(
                  type: _AlertType.follower,
                  title: 'New Follower',
                  description: 'Martin started following your posts',
                  time: '4 hours ago',
                ),
                _buildAlertCard(
                  type: _AlertType.follower,
                  title: 'New Follower',
                  description: 'Aish started following your posts',
                  time: '5 hours ago',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      // Using moderate top padding assuming this sits below the global AppBar in MainShellCoordinator
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF0F9D58),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alerts',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stay connected with your community',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '2 New',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required _AlertType type,
    required String title,
    required String description,
    required String time,
    bool isNew = false,
    bool hasActions = false,
  }) {
    Color borderColor = Colors.grey.withOpacity(0.1);
    if (type == _AlertType.claim && isNew) borderColor = Colors.green.withOpacity(0.3);
    if (type == _AlertType.nearby && isNew) borderColor = Colors.orange.withOpacity(0.3);

    Color? accentColor;
    if (type == _AlertType.claim && isNew) accentColor = Colors.green;
    if (type == _AlertType.nearby && isNew) accentColor = Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Left Accent Line for New Items
          if (accentColor != null)
            Positioned(
              left: 0,
              top: 24,
              bottom: 24,
              child: Container(
                width: 5,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIconForType(type, isNew),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2D3142),
                            ),
                          ),
                          Text(
                            time,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isNew ? const Color(0xFF0F9D58) : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (hasActions) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F9D58),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'View Details',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey[100],
                                foregroundColor: Colors.grey[700],
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Dismiss',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconForType(_AlertType type, bool isNew) {
    Widget mainIcon;
    Widget? bottomBadge;

    switch (type) {
      case _AlertType.claim:
        mainIcon = const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFEDF2FA),
          child: Icon(Icons.person, color: Color(0xFF5C6BC0), size: 28),
        );
        bottomBadge = Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: Color(0xFF0F9D58), size: 16),
        );
        break;
      case _AlertType.nearby:
        mainIcon = Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFF7043), // Vibrant Orange
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
        );
        break;
      case _AlertType.follower:
        mainIcon = const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFEDF2FA),
          child: Icon(Icons.person, color: Color(0xFF5C6BC0), size: 28),
        );
        bottomBadge = Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_add_alt_1, color: Color(0xFF4285F4), size: 14),
        );
        break;
      case _AlertType.expiry:
        mainIcon = Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE53935), // Red
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.access_time, color: Colors.white, size: 24),
        );
        break;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        mainIcon,
        if (isNew)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF0F9D58),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
            ),
          ),
        if (bottomBadge != null)
          Positioned(
            bottom: -4,
            right: -4,
            child: bottomBadge,
          ),
      ],
    );
  }
}
