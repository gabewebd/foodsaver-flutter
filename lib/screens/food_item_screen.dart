import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/food_listing.dart';
import '../data/supabase_service.dart';
import '../utils/date_utils.dart';
import 'home_feed_screen.dart';

// Yamzon: Welcome sa detail page ng mga pagkain!
// Dito makikita ni user lahat ng info bago niya i-claim yung item.
class FoodItemScreen extends StatefulWidget {
  final FoodListing foodData;

  const FoodItemScreen({super.key, required this.foodData});

  @override
  State<FoodItemScreen> createState() => _FoodItemScreenState();
}

class _FoodItemScreenState extends State<FoodItemScreen> {
  bool _isClaiming = false;
  late FoodListing _currentData;

  @override
  void initState() {
    super.initState();
    _currentData = widget.foodData;
  }

  String _getExpiryText() {
    if (_currentData.expiryDate == null) return 'Flexible window';
    return 'Expires ${TimeUtils.formatFullDate(_currentData.expiryDate!)}';
  }

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF0F9D58);
    final String timeAgo = TimeUtils.getTimeAgo(_currentData.createdAt);

    return Scaffold(
      backgroundColor: brandGreen,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ColoredBox(
              color: Colors.white,
              child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                   _buildItemImage(timeAgo),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          _currentData.grabTitle,
                          style: GoogleFonts.nunito(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStatusTag(
                              _getStatusText(_currentData),
                              _getStatusColor(_currentData).withOpacity(0.1),
                              _getStatusColor(_currentData),
                              icon: _getStatusIcon(_currentData),
                            ),
                            const SizedBox(width: 8),
                            if (!_currentData.isClaimed && !_currentData.isCompleted)
                              _buildStatusTag(
                                _currentData.expiryDate != null 
                                    ? 'Expires ${TimeUtils.formatFullDate(_currentData.expiryDate!)}'
                                    : 'Expires ${_currentData.timeWindow}',
                                const Color(0xFFFFEBEE),
                                const Color(0xFFD32F2F),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildUserRow(),
                        const Divider(height: 48, color: Color(0xFFF3F4F6)),
                        _buildLocationSection(),
                        const SizedBox(height: 32),
                        _buildDescriptionSection(),
                        const SizedBox(height: 40),
                        _buildClaimButton(context),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 24, left: 16, right: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F9D58),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            padding: const EdgeInsets.all(12),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Item Details',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Offered by ${_currentData.posterAlias}',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage(String timeAgo) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: _currentData.offlineImage.startsWith('http')
                  ? NetworkImage(_currentData.offlineImage)
                  : AssetImage(_currentData.offlineImage) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEF5350),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  timeAgo,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTag(String text, Color bgColor, Color textColor, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.nunito(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow() {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFF3F4F6),
          backgroundImage: _currentData.posterAvatarUrl != null
              ? NetworkImage(_currentData.posterAvatarUrl!)
              : null,
          child: _currentData.posterAvatarUrl == null ? const Icon(Icons.person) : null,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _currentData.posterAlias,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F9D58),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            Text(
              'Posted ${TimeUtils.getTimeAgo(_currentData.createdAt)}',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.location_on_outlined, color: Color(0xFF0F9D58)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pickup Location',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _currentData.meetupSpot,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D3142),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _currentData.backstory,
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: const Color(0xFF4B5563),
            fontWeight: FontWeight.w600,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildClaimButton(BuildContext context) {
    const Color accentOrange = Color(0xFFE65100);
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: _currentData.isClaimed
            ? null
            : () async {
                try {
                  final myProfile = await SupabaseService.getCurrentUserProfile();
                  final myName = myProfile?['full_name'] ?? 'Anonymous Eco Warrior';

                  await SupabaseService.claimItem(
                    _currentData.entryId,
                    _currentData.grabTitle,
                    myName,
                    _currentData.userId ?? '',
                    SupabaseService.currentUserId ?? '',
                  );
                  if (!context.mounted) return;

                  // Translated to English as per user request (Image 3)
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      title: const Text('Yehey!'),
                      content: const Text('You have successfully claimed this item. Please proceed to the meetup spot!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text('Got it!', style: TextStyle(color: Color(0xFF0F9D58), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error claiming: $e'), backgroundColor: Colors.red),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 24),
            const SizedBox(width: 12),
            Text(
              _currentData.isClaimed ? 'Already Claimed' : 'Claim This Item',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _getStatusText(FoodListing item) {
    if (item.isCompleted) return 'Completed';
    if (item.isClaimed) return 'Claimed';
    return 'Available';
  }

  Color _getStatusColor(FoodListing item) {
    if (item.isCompleted) return const Color(0xFF0F9D58);
    if (item.isClaimed) return Colors.orange;
    return const Color(0xFF0F9D58);
  }

  IconData _getStatusIcon(FoodListing item) {
    if (item.isCompleted) return Icons.check_circle;
    if (item.isClaimed) return Icons.access_time_filled;
    return Icons.inventory_2_outlined;
  }
}

