import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_data.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final List<FoodListing> listings = FoodListing.fetchMockData();
  String selectedCategory = 'All';

  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.auto_awesome_outlined},
    {'name': 'Urgent', 'icon': Icons.local_fire_department_outlined},
    {'name': 'Nearby', 'icon': Icons.location_on_outlined},
    {'name': 'Popular', 'icon': Icons.trending_up_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    // Screen is used inside MainShellCoordinator, so we return only the body content.
    return Container(
      color: const Color(0xFFF1F8F1), // Consistent background color
      child: Column(
        children: [
          _buildSearchAndFilters(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                return _buildFoodCard(listings[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// This section contains the Search Bar and Category Chips.
  /// It uses the brand green color to blend perfectly with the global AppBar.
  Widget _buildSearchAndFilters(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      decoration: BoxDecoration(
        color: primaryColor,
        // No top rounding needed as it sits flush under the AppBar
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: GoogleFonts.nunito(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Search for food items...',
                      hintStyle: GoogleFonts.nunito(
                        color: Colors.grey[500],
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: categories.map((cat) {
                bool isSelected = selectedCategory == cat['name'];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => selectedCategory = cat['name']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            cat['icon'],
                            color: isSelected ? primaryColor : Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat['name'],
                            style: GoogleFonts.nunito(
                              color: isSelected ? primaryColor : Colors.white,
                              fontWeight: FontWeight.w700,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail Stack
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    item.offlineImage,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
                // Urgent Tag
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2D36),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.white, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          'Urgent',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Favorite Button
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1))]
                    ),
                    child: const Icon(Icons.favorite, color: Color(0xFFFF2D36), size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Info Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.grabTitle.split(' (')[0],
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D3142),
                    ),
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
                          item.meetupSpot.split(',')[0],
                          style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CircleAvatar(radius: 10, backgroundColor: Colors.grey[100], child: const Icon(Icons.person, size: 12, color: Colors.grey)),
                      const SizedBox(width: 6),
                      Text(item.posterAlias, style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildTag(item.timeWindow.contains('hours') ? item.timeWindow : '3 hours', const Color(0xFFFFF4EC), Colors.orange),
                      const SizedBox(width: 8),
                      _buildTag(item.dropDistance, const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: GoogleFonts.nunito(color: textColor, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}
