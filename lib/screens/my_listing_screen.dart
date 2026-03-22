import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food_listing.dart';
import '../data/supabase_service.dart';
import '../utils/date_utils.dart';
import 'share_food_screen.dart';
import '../utils/error_utils.dart';

// Velasquez: Mark Dave, inayos ko na yung dual UI states dito. 
// Gumagana na yung "Waiting for Claim" at "Claimed By" states, wag niyo na galawin please.
// Nakaka-stress na 'tong Supabase sync buti na-fix ko na.
class MyListingScreen extends StatefulWidget {
  final FoodListing foodData;

  const MyListingScreen({super.key, required this.foodData});

  @override
  State<MyListingScreen> createState() => _MyListingScreenState();
}

class _MyListingScreenState extends State<MyListingScreen> {
  bool _isProcessing = false;
  late FoodListing _currentFoodData;

  @override
  void initState() {
    super.initState();
    // Yamzon, sabi mo nag-ccrash dito pag mabilis yung transition? 
    // Nilipat ko yung assignment para safe.
    _currentFoodData = widget.foodData;
  }

  Future<void> _handleConfirm() async {
    if (_isProcessing) return;
    if (_currentFoodData.claimerId == null || _currentFoodData.claimerId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot confirm: Claimer information is missing.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      await SupabaseService.confirmPickup(_currentFoodData.entryId, _currentFoodData.claimerId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing completed! Thank you.'), backgroundColor: Color(0xFF0F9D58)),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorUtils.getFriendlyErrorMessage(e)), 
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleReject() async {
    if (_isProcessing) return;
    // Yamzon, bypass muna natin yung claimerId check dito para ma-clear yung "broken" state 
    // kung sakaling nag-loko yung stream. Inhandle na rin to sa Supabase side para iwas crash.

    setState(() => _isProcessing = true);
    try {
      await SupabaseService.rejectPickup(_currentFoodData.entryId, _currentFoodData.claimerId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pickup cancelled. Listing is back online.'), backgroundColor: Colors.orange),
      );
      // Update local state to show "Waiting for claim"
      setState(() {
        _currentFoodData = _currentFoodData.copyWith(
          isClaimed: false,
          claimerId: null,
          claimerName: null,
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorUtils.getFriendlyErrorMessage(e)), 
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF0F9D58);
    return Scaffold(
      backgroundColor: brandGreen,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ColoredBox(
                  color: const Color(0xFFF1F8F1),
                  child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildMainCard(),
                      Container(
                        width: double.infinity,
                        color: (_currentFoodData.isClaimed || _currentFoodData.isCompleted) 
                            ? const Color(0xFFF1F8F1) 
                            : Colors.transparent,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            if (_currentFoodData.isCompleted)
                              _buildCompletedSection()
                            else if (_isExpired(_currentFoodData))
                              _buildExpiredSection()
                            else if (_currentFoodData.isClaimed)
                              _buildClaimedSection()
                            else
                              _buildWaitingSection(),
                            const SizedBox(height: 32),
                            _buildBottomActions(),
                            const SizedBox(height: 32),
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
        if (_isProcessing)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
      ],
    ),
  );
}

  bool _isExpired(FoodListing item) {
    if (item.isCompleted) return false;
    if (item.expiryDate == null) return false;
    return item.expiryDate!.isBefore(DateTime.now());
  }

  Widget _buildHeader(BuildContext context) {
    const Color brandGreen = Color(0xFF0F9D58);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: brandGreen,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0x33FFFFFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Listing',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Posted ${TimeUtils.getTimeAgo(_currentFoodData.createdAt)}',
                style: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemImage(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentFoodData.grabTitle,
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (_currentFoodData.category != null)
                      _buildTag(_currentFoodData.category!, const Color(0xFFE8F5E9), const Color(0xFF4CAF50)),
                    if (_currentFoodData.category != null && _currentFoodData.expiryDate != null)
                      const SizedBox(width: 8),
                    if (_currentFoodData.expiryDate != null)
                      _buildTag(
                        _isExpired(_currentFoodData) 
                          ? 'Expired: ${TimeUtils.formatShortDate(_currentFoodData.expiryDate)}' 
                          : 'Expires: ${TimeUtils.formatShortDate(_currentFoodData.expiryDate)}', 
                        _isExpired(_currentFoodData) ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0), 
                        _isExpired(_currentFoodData) ? Colors.red : const Color(0xFFFF9800)
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _currentFoodData.backstory,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 8),
                    Text(
                      _currentFoodData.meetupSpot,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildItemImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _currentFoodData.offlineImage.startsWith('http')
                  ? Image.network(_currentFoodData.offlineImage, fit: BoxFit.cover)
                  : Image.asset(_currentFoodData.offlineImage, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: _buildStatusBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isClaimed = _currentFoodData.isClaimed;
    final isCompleted = _currentFoodData.isCompleted;
    
    Color color = const Color(0xFFFF9800); // Orange to para mainit pa
    IconData icon = Icons.access_time_filled;
    String label = 'Available';

    if (isCompleted) {
      color = const Color(0xFF4CAF50); // Green na so tapos na 'to
      icon = Icons.check_circle;
      label = 'Completed';
    } else if (_isExpired(_currentFoodData)) {
      color = Colors.red; // Pula pag expired na pre, wag na kainin
      icon = Icons.event_busy;
      label = 'Expired';
    } else if (isClaimed) {
      color = Colors.orange; // Claimed na pero di pa nakukuha
      icon = Icons.access_time_filled;
      label = 'Claimed';
    } else {
      color = const Color(0xFF4CAF50); // Available pa, go lang
      icon = Icons.inventory_2_outlined;
      label = 'Available';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildWaitingSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFFFE0B2), width: 1),
      ),
      child: Column(
        children: [
          const Icon(Icons.access_time_filled, color: Color(0xFFFF9800), size: 64),
          const SizedBox(height: 20),
          Text(
            'Waiting for Claim',
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your item has been posted. You\'ll be notified when someone claims it!',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Color(0xFFFFB300), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tip: Items with clear photos get claimed faster!',
                    style: GoogleFonts.nunito(
                      color: const Color(0xFF8D6E63),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF0F9D58), size: 64),
          const SizedBox(height: 20),
          Text(
            'Picked Up!',
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Item successfully picked up. Thank you for making a difference!',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_busy, color: Colors.red, size: 64),
          const SizedBox(height: 20),
          Text(
            'Item Expired',
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This item has expired. It was not claimed or confirmed picked up before the deadline.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimedSection() {
    return FutureBuilder<Map<String, dynamic>?>(
      // Yamaguchi: Dito yung hila ng profile, paki-check kung tama yung avatar
      // Minsan kasi blanko yung avatar_url pag bago yung user.
      future: SupabaseService.getClaimerProfile(_currentFoodData.claimerId ?? ''),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              ErrorUtils.getFriendlyErrorMessage(snapshot.error!),
              style: GoogleFonts.nunito(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          );
        }
        
        final profile = snapshot.data;
        final claimerName = profile?['full_name'] ?? _currentFoodData.claimerName ?? 'Eco Warrior';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Color(0xFF4CAF50), size: 24),
                const SizedBox(width: 12),
                Text(
                  'Claimed By',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2D3142),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: profile?['avatar_url'] != null ? NetworkImage(profile!['avatar_url']) : null,
                    backgroundColor: Colors.white,
                    child: profile?['avatar_url'] == null ? const Icon(Icons.person, color: Color(0xFF4CAF50), size: 30) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          claimerName,
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                        Text(
                          profile?['building_no'] ?? 'Verified member',
                          style: GoogleFonts.nunito(color: const Color(0xFF6B7280), fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          'Claimed 1 minute ago',
                          style: GoogleFonts.nunito(color: const Color(0xFF4CAF50), fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                // Velasquez: I-trigger natin yung popup dito, ipasa yung ID para ma-fetch yung number sa profiles table.
                onPressed: () => _showContactDetailsDialog(context, _currentFoodData.claimerId!, claimerName),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Send Message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildConfirmPickupSection(claimerName),
          ],
        );
      },
    );
  }

  Widget _buildConfirmPickupSection(String claimerName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0E7FF), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm Pickup',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 16, color: const Color(0xFF2D3142)),
                ),
                Text(
                  'Did $claimerName pick it up?',
                  style: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFF6B7280), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _confirmPickupDialog(context, claimerName),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _confirmReject(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF1744),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    const Color brandGreen = Color(0xFF0F9D58);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShareFoodScreen(existingItem: _currentFoodData),
                ),
              ).then((_) async {
                if (mounted) {
                  final updatedItem = await SupabaseService.getFoodListingById(_currentFoodData.entryId);
                  if (updatedItem != null && mounted) {
                    setState(() {
                      _currentFoodData = updatedItem;
                    });
                  }
                }
              });
            },
            icon: const Icon(Icons.edit_note),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.5),
              foregroundColor: const Color(0xFF4285F4),
              side: const BorderSide(color: Color(0xFF4285F4), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.5),
              foregroundColor: const Color(0xFFD32F2F),
              side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('Are you sure you want to remove this food listing? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await SupabaseService.deleteListing(_currentFoodData.entryId);
              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmReject(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Pickup?'),
        content: const Text('Are you sure you want to cancel this pickup? The item will be available for others to claim again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No, keep it')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleReject();
            },
            child: const Text('Yes, cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmPickupDialog(BuildContext context, String claimerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Confirm Pickup?', style: GoogleFonts.nunito(fontWeight: FontWeight.w900)),
        content: Text('Are you sure this item has been picked up by $claimerName? This will mark the listing as completed.', 
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Not yet', style: GoogleFonts.nunito(color: Colors.grey, fontWeight: FontWeight.w800)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleConfirm();
            },
            child: Text('Yes, confirmed', style: GoogleFonts.nunito(color: const Color(0xFF0F9D58), fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
  Future<void> _showContactDetailsDialog(BuildContext context, String claimerId, String claimerName) async {
    // Velasquez: Loader muna tayo pre bago ipakita yung phone number, mahirap na pag null-pointer.
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: FutureBuilder<Map<String, dynamic>>(
            future: Supabase.instance.client
                .from('profiles')
                .select('phone_number, building_no')
                .eq('id', claimerId)
                .single(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF4285F4))),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    ErrorUtils.getFriendlyErrorMessage(snapshot.error!),
                    style: GoogleFonts.nunito(color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                );
              }

              final profile = snapshot.data!;
              final phoneNumber = profile['phone_number'] ?? 'N/A';
              final buildingNo = profile['building_no'] ?? 'Verified member';

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   // Header: Blue container (Colors.blue[600])
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    color: Colors.blue[600],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Contact Details',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                        Text(
                          'Reach out to confirm pickup',
                          style: GoogleFonts.nunito(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                   // Body
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                         // Profile Row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xFF0F9D58),
                              child: Text(
                                claimerName.isNotEmpty ? claimerName[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    claimerName,
                                    style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900),
                                  ),
                                  Text(
                                    buildingNo,
                                    style: GoogleFonts.nunito(color: Colors.grey[600], fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                         // Phone Container
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F8F1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.phone_outlined, color: Color(0xFF0F9D58)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Phone Number',
                                    style: GoogleFonts.nunito(
                                      color: const Color(0xFF2D3142),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    phoneNumber,
                                    style: GoogleFonts.nunito(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                         // Action Buttons Row
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => launchUrl(Uri.parse('sms:$phoneNumber')),
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: const Text('Send Message'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4285F4),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                  textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                               onTap: () => launchUrl(Uri.parse('tel:$phoneNumber')),
                               child: Container(
                                 padding: const EdgeInsets.all(18),
                                 decoration: BoxDecoration(
                                   color: const Color(0xFF0F9D58),
                                   borderRadius: BorderRadius.circular(16),
                                 ),
                                 child: const Icon(Icons.phone, color: Colors.white),
                               ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// Velasquez: Extension 'to para iwas boilerplate pag mag-update ng UI state.
// Wag niyo niyo 'to buburahin or babaguhin yung logic, masisira yung inventory system natin.
extension FoodListingExtension on FoodListing {
  FoodListing copyWith({
    bool? isClaimed,
    bool? isCompleted,
    String? claimerId,
    String? claimerName,
    String? category,
    DateTime? expiryDate,
  }) {
    return FoodListing(
      entryId: entryId,
      grabTitle: grabTitle,
      backstory: backstory,
      timeWindow: timeWindow,
      dropDistance: dropDistance,
      meetupSpot: meetupSpot,
      posterAlias: posterAlias,
      posterAvatarUrl: posterAvatarUrl,
      userId: userId,
      claimerId: claimerId ?? this.claimerId,
      offlineImage: offlineImage,
      imageBytes: imageBytes,
      createdAt: createdAt,
      isClaimed: isClaimed ?? this.isClaimed,
      isCompleted: isCompleted ?? this.isCompleted,
      claimerName: claimerName ?? this.claimerName,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}
