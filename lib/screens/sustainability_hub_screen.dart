import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/supabase_service.dart'; 
import '../utils/date_utils.dart';
import '../models/food_listing.dart';
import 'my_listing_screen.dart'; 
import 'food_item_screen.dart'; // Added for Claimed Item Navigation

// Mark Dave, Welcome sa Sustainability Hub natin! 
// Dito mo makikita yung impact mo sa community at yung sarili mong listings.
class SustainabilityHubScreen extends StatefulWidget {
  const SustainabilityHubScreen({super.key});

  @override
  State<SustainabilityHubScreen> createState() => _SustainabilityHubScreenState();
}

class _SustainabilityHubScreenState extends State<SustainabilityHubScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    // Mark Dave, Hinihila natin yung stats mo mula sa database.
                    FutureBuilder<Map<String, int>>(
                      future: SupabaseService.getUserMetrics(),
                      builder: (context, snapshot) {
                        final shared = snapshot.data?['shared'] ?? 0;
                        final claimed = snapshot.data?['claimed'] ?? 0;
                        return _buildStatsRow(shared.toString(), claimed.toString());
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildListingsSection(context),
                    const SizedBox(height: 24),
                    _buildClaimedItemsSection(context), // New Section
                    const SizedBox(height: 24),
                    _buildDailyTipSection(),
                    const SizedBox(height: 30),
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
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF0F9D58),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sustainability Hub',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your impact matters!',
                style: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: () async {
                  // Mark Dave, Para makapag-switch ng account si user.
                  await SupabaseService.logoutUser();
                  if (!context.mounted) return;
                  // Velasquez: Reload the app to hit AuthGate logic.
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: SupabaseService.getCurrentUserProfile(),
      builder: (context, snapshot) {
        // Mark Dave, habang naglo-load, pakitaan muna natin ng loading state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final profileData = snapshot.data;
        final fullName = profileData?['full_name'] ?? 'Eco Warrior User';
        final avatarUrl = profileData?['avatar_url'];
        final buildingNo = profileData?['building_no'] ?? 'Active Member';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2E7D32), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFFE8F5E9),
                      // Mark Dave, ito yung dynamic avatar url natin!
                      // Ginamit natin yung PNG version para diretsong load sa NetworkImage.
                      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null 
                        ? const Icon(Icons.person, size: 35, color: Colors.grey) 
                        : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F9D58),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.link, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                    Text(
                      'Eco Warrior • $buildingNo',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.emoji_events_outlined,
                            color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Contributor',
                          style: GoogleFonts.nunito(
                            color: Colors.orange[800],
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
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
      },
    );
  }

  Widget _buildStatsRow(String shared, String claimed) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.share_outlined,
            value: shared,
            label: 'Items Shared',
            color: const Color(0xFF0F9D58),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.inventory_2_outlined,
            value: claimed,
            label: 'Items Claimed',
            color: const Color(0xFFF57C00),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.orange.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF57C00),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                'My Listings',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D3142),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mark Dave, Nililimit natin sa 3 latest listings para hindi siksikan.
          StreamBuilder<List<FoodListing>>(
            stream: SupabaseService.getFoodStream(),
            builder: (context, snapshot) {
              // Task 3: Explicitly catch and display errors
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Stream Error: ${snapshot.error}', 
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final allListings = snapshot.data ?? [];
              // Senior Architect Note: Using custom currentUserId for filtering.
              final myListings = allListings.where((item) => item.userId == SupabaseService.currentUserId).toList();

              if (myListings.isEmpty) {
                return Text('No listings shared yet.', style: GoogleFonts.nunito(color: Colors.grey));
              }

              return Column(
                children: myListings.take(3).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyListingScreen(foodData: item),
                        ),
                      ).then((_) {
                        if (mounted) setState(() {});
                      });
                    },
                    child: _buildListingItem(
                      title: item.grabTitle,
                      item: item,
                      imagePath: item.offlineImage,
                      timeAgo: TimeUtils.getTimeAgo(item.createdAt),
                    ),
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClaimedItemsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF0F9D58).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F9D58),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                'Items I\'ve Claimed',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D3142),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<FoodListing>>(
            stream: SupabaseService.getFoodStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final allListings = snapshot.data ?? [];
              final myClaims = allListings.where((item) => item.claimerId == SupabaseService.currentUserId).toList();

              if (myClaims.isEmpty) {
                return Text('You haven\'t claimed any items yet.', style: GoogleFonts.nunito(color: Colors.grey));
              }

              return Column(
                children: myClaims.take(3).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodItemScreen(foodData: item),
                        ),
                      ).then((_) {
                        if (mounted) setState(() {});
                      });
                    },
                    child: _buildListingItem(
                      title: item.grabTitle,
                      item: item,
                      imagePath: item.offlineImage,
                      timeAgo: TimeUtils.getTimeAgo(item.createdAt),
                    ),
                  ),
                )).toList(),
              );
            },
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


  Widget _buildListingItem({
    required String title,
    required FoodListing item,
    required String imagePath,
    String? timeAgo,
  }) {
    String status = 'Available';
    Color statusColor = const Color(0xFF0F9D58);
    bool expired = _isExpired(item);

    if (item.isCompleted) {
      status = 'Completed';
      statusColor = const Color(0xFF0F9D58);
    } else if (expired) {
      status = 'Expired';
      statusColor = Colors.red;
    } else if (item.isClaimed) {
      status = item.claimerId == SupabaseService.currentUserId ? 'Claimed by You' : 'Claimed';
      statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imagePath.startsWith('http')
              ? Image.network(imagePath, width: 50, height: 50, fit: BoxFit.cover)
              : Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D3142),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (timeAgo != null)
                      Text(
                        timeAgo,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.nunito(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
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

  Widget _buildDailyTipSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF4285F4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.priority_high,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                'Daily Tip',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D3142),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'For stray cats, avoid onions, garlic, and seasoned, fatty, or chocolate.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: const Color(0xFF1565C0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAF6),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_up, color: Color(0xFF3949AB), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Making a difference!',
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF3949AB),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
