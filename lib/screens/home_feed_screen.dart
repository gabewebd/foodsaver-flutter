import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/food_listing.dart';
import '../data/supabase_service.dart'; 
import '../utils/date_utils.dart'; // Unified Time Utils
import 'food_item_screen.dart';
import 'my_listing_screen.dart'; 

// Aguiluz, Welcome sa updated main feed natin pre! 
// Tinanggal na natin yung fake filters, real-time na yung time-based filtering natin.
// Velasquez: Paki-check if mabilis mag-load yung stream, baka mag-lag sa dami ng listings.
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.auto_awesome_outlined},
    {'name': 'Urgent', 'icon': Icons.local_fire_department_outlined}, // <= 24 hours
    {'name': 'Soon', 'icon': Icons.timer_outlined}, // 1 - 3 days
    {'name': 'Flexible', 'icon': Icons.calendar_today_outlined}, // >= 4 days or none
  ];

  // Aguiluz, Ito yung logic natin para sa "Urgent" badge. 
  // Paki-try catch to pre, baka biglang mag-crash pag null yung date.
  bool _isUrgent(FoodListing item) {
    try {
      final expiry = DateTime.tryParse(item.timeWindow);
      if (expiry == null) return false; // Fallback for old text data
      return expiry.difference(DateTime.now()).inHours <= 24;
    } catch (e) {
      return false; // Task 4: Return false instead of crashing
    }
  }

  // Aguiluz, "New" badge logic. Pag na-post sa loob ng last 12 hours.
  bool _isNew(FoodListing item) {
    return item.createdAt.isAfter(DateTime.now().subtract(const Duration(hours: 12)));
  }

  bool _isExpired(FoodListing item) {
    if (item.isCompleted) return false;
    if (item.expiryDate == null) return false;
    return item.expiryDate!.isBefore(DateTime.now());
  }

  // Aguiluz, updated filter logic para sa Categories at Search.
  List<FoodListing> _applyFilters(List<FoodListing> allListings) {
    List<FoodListing> filtered = allListings;

    // Filter by Category
    // Base rule: items without expiry are 'Flexible'
    bool isFlexibleOrNull(FoodListing item) {
      if (item.expiryDate == null) return true;
      return item.expiryDate!.difference(DateTime.now()).inHours > 72;
    }

    bool isSoon(FoodListing item) {
      if (item.expiryDate == null) return false;
      final hr = item.expiryDate!.difference(DateTime.now()).inHours;
      return hr > 24 && hr <= 72;
    }

    // Default sorting helper (closest expiry first, nulls at bottom)
    int defaultSort(FoodListing a, FoodListing b) {
      if (a.expiryDate == null && b.expiryDate == null) return 0;
      if (a.expiryDate == null) return 1;
      if (b.expiryDate == null) return -1;
      return a.expiryDate!.compareTo(b.expiryDate!);
    }

    if (_selectedFilter == 'Urgent') {
      filtered = filtered.toList()..sort((a, b) {
        final aTarget = _isUrgent(a);
        final bTarget = _isUrgent(b);
        if (aTarget && !bTarget) return -1;
        if (!aTarget && bTarget) return 1;
        return defaultSort(a, b);
      });
    } else if (_selectedFilter == 'Soon') {
      filtered = filtered.toList()..sort((a, b) {
        final aTarget = isSoon(a);
        final bTarget = isSoon(b);
        if (aTarget && !bTarget) return -1;
        if (!aTarget && bTarget) return 1;
        return defaultSort(a, b);
      });
    } else if (_selectedFilter == 'Flexible') {
      filtered = filtered.toList()..sort((a, b) {
        final aTarget = isFlexibleOrNull(a);
        final bTarget = isFlexibleOrNull(b);
        if (aTarget && !bTarget) return -1;
        if (!aTarget && bTarget) return 1;
        // if both are flexible, sort by newest created
        if (aTarget && bTarget) return b.createdAt.compareTo(a.createdAt);
        return defaultSort(a, b);
      });
    } else {
      // "All" filter logic: show all active, sorted by nearest expiry by default
      filtered = filtered.toList()..sort(defaultSort);
    }

    // Filter by Search Keyword
    final keyword = _searchController.text.toLowerCase();
    if (keyword.isNotEmpty) {
      filtered = filtered.where((item) => item.grabTitle.toLowerCase().contains(keyword)).toList();
    }

    // Task 2 & User Request: Hide completed, expired, and claimed items from the feed
    filtered = filtered.where((item) => !item.isCompleted && !item.isClaimed && !_isExpired(item)).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F8F1), 
      child: Column(
        children: [
          _buildSearchAndFilters(context),
          Expanded(
            child: StreamBuilder<List<FoodListing>>(
              stream: SupabaseService.getFoodStream(),
              builder: (context, snapshot) {
                // Task 3: Explicitly catch and display errors
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Stream Error: ${snapshot.error}', 
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF0F9D58)));
                }
                
                final allListings = snapshot.data ?? [];
                if (allListings.isEmpty) {
                  return Center(
                    child: Text(
                      'No food items shared yet.',
                      style: GoogleFonts.nunito(color: Colors.grey),
                    ),
                  );
                }

                final filteredListings = _applyFilters(allListings);
                
                if (filteredListings.isEmpty) {
                  return Center(
                    child: Text(
                      'No items match your filter.',
                      style: GoogleFonts.nunito(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 10),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredListings.length,
                  itemBuilder: (context, index) {
                    return _buildFoodCard(filteredListings[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 60),
      decoration: BoxDecoration(color: primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task 5: Column for title and restored tagline
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FoodSaver',
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                "Don't Waste It. Share It.",
                style: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search for food items...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: categories.map((cat) {
                bool isSelected = _selectedFilter == cat['name'];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = cat['name']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        // Aguiluz: Updated colors based sa UI reference ni Mark Dave. 
                        // Active = White pill, Green text. Inactive = Translucent White.
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat['icon'],
                            color: isSelected ? const Color(0xFF0F9D58) : Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cat['name'],
                            style: GoogleFonts.nunito(
                              color: isSelected ? const Color(0xFF0F9D58) : Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(FoodListing item) {
    final expiryInfo = TimeUtils.getExpiresIn(item.expiryDate);
    final String expiryText = expiryInfo.$1;
    final Color expiryColor = expiryInfo.$2;

    String badgeText = 'Flexible';
    if (expiryColor == Colors.red) {
      badgeText = 'Urgent';
    } else if (expiryColor == Colors.orange) {
      badgeText = 'Soon';
    }

    return GestureDetector(
      onTap: () {
        final isOwner = item.userId == SupabaseService.currentUserId;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => isOwner ? MyListingScreen(foodData: item) : FoodItemScreen(foodData: item),
          ),
        ).then((_) {
          if (mounted) setState(() {});
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: item.offlineImage.startsWith('http') 
                        ? Image.network(item.offlineImage, width: 100, height: 100, fit: BoxFit.cover)
                        : Image.asset(item.offlineImage, width: 100, height: 100, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: _buildBadge(badgeText, expiryColor),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.grabTitle,
                      style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF2D3142)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF0F9D58)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.meetupSpot,
                            style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: item.posterAvatarUrl != null ? NetworkImage(item.posterAvatarUrl!) : null,
                          backgroundColor: const Color(0xFFE8F5E9),
                          child: item.posterAvatarUrl == null ? const Icon(Icons.person, size: 14, color: Color(0xFF0F9D58)) : null,
                        ),
                        const SizedBox(width: 8),
                        Text(item.posterAlias, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF2D3142))),
                        const Spacer(),
                        Text(
                          TimeUtils.getTimeAgo(item.createdAt),
                          style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      expiryText,
                      style: GoogleFonts.nunito(fontSize: 12, color: expiryColor, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: GoogleFonts.nunito(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }

}
