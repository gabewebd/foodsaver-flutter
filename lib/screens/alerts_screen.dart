import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/alert_listing.dart';
import '../data/supabase_service.dart';
import '../utils/date_utils.dart';

// Yamaguchi, Dito mo na-monitor lahat ng ganap sa app. 
// Stay updated pre para mabilis yung response sa mga claims!
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      body: StreamBuilder<List<AlertListing>>(
        // Yamaguchi: Real-time stream to pre, no need to refresh. Matic lilitaw yung bago.
        stream: SupabaseService.getAlertsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = snapshot.data ?? [];
          final newCount = alerts.where((a) => a.isNew).length;

          return Column(
            children: [
              _buildHeader(context, newCount),
              Expanded(
                child: alerts.isEmpty 
                  ? Center(child: Text('No alerts yet.', style: GoogleFonts.nunito(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return _buildAlertCard(context, alert);
                      },
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int newCount) {
    return Container(
      width: double.infinity,
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
              '$newCount New',
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


  Widget _buildAlertCard(BuildContext context, AlertListing alert) {
    bool isGreen = (alert.type == AlertType.claim || alert.type == AlertType.success) && alert.isNew;
    bool isOrange = (alert.type == AlertType.nearby || alert.type == AlertType.warning) && alert.isNew;
    
    Color borderColor = Colors.grey.withOpacity(0.1);
    if (isGreen) borderColor = const Color(0xFF0F9D58).withOpacity(0.3);
    if (isOrange) borderColor = const Color(0xFFF57C00).withOpacity(0.3);
    Color? accentColor;
    if (isGreen) accentColor = const Color(0xFF0F9D58);
    if (isOrange) accentColor = const Color(0xFFF57C00);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        // Task 3: Border only for NEw alerts
        border: alert.isNew ? Border.all(color: accentColor?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.1), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Accent Bar (Image 1)
            if (alert.isNew && accentColor != null)
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIconForType(alert.type, alert.isNew, alert.senderAvatar),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      alert.title,
                                      style: GoogleFonts.nunito(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF2D3142),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    TimeUtils.getTimeAgo(alert.createdAt),
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: alert.isNew ? const Color(0xFF0F9D58) : Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                alert.description,
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6B7280),
                                  height: 1.3,
                                ),
                              ),
                              if (alert.hasActions && alert.isNew) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        // Task: Navigate to details then mark as viewed
                                        await SupabaseService.markAlertAsViewed(alert.alertId);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF00C853), // Vibrant Green (Image 1)
                                        foregroundColor: Colors.white,
                                        elevation: 2,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                        minimumSize: const Size(0, 42),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                      child: Text('View Details', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900)),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await SupabaseService.markAlertAsViewed(alert.alertId);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF3F4F6),
                                        foregroundColor: const Color(0xFF4B5563),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                        minimumSize: const Size(0, 42),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                      child: Text('Dismiss', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900)),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconForType(AlertType type, bool isNew, String? avatarUrl) {
    Widget mainIcon;
    Widget? bottomBadge;

    switch (type) {
      case AlertType.claim:
      case AlertType.success:
      case AlertType.follower:
        mainIcon = CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFFF1F5F9),
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null ? const Icon(Icons.person, color: Color(0xFF64748B), size: 30) : null,
        );
        
        IconData badgeIcon = Icons.check_circle;
        Color badgeColor = const Color(0xFF0F9D58);
        if (type == AlertType.follower) {
          badgeIcon = Icons.person_add_alt_1;
          badgeColor = const Color(0xFF4285F4);
        }

        bottomBadge = Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(badgeIcon, color: badgeColor, size: 18),
        );
        break;
      case AlertType.nearby:
        mainIcon = Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF57C00),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
        );
        break;
      case AlertType.expiry:
      case AlertType.warning:
        mainIcon = Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: type == AlertType.expiry ? const Color(0xFFEF4444) : const Color(0xFFF57C00),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(type == AlertType.expiry ? Icons.access_time : Icons.warning_amber_rounded, color: Colors.white, size: 28),
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
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF0F9D58),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
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
