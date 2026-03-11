import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_data.dart';
import 'food_item_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.auto_awesome_outlined},
    {'name': 'Urgent', 'icon': Icons.local_fire_department_outlined},
    {'name': 'Nearby', 'icon': Icons.location_on_outlined},
    {'name': 'Popular', 'icon': Icons.trending_up_outlined},
  ];

  String selectedCategory = 'All';

  List<FoodListing> _filterListings(List<FoodListing> allListings, String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      return allListings;
    } else {
      return allListings
          .where((item) =>
              item.grabTitle.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F8F1),
      child: Column(
        children: [
          _buildSearchAndFilters(context),
          Expanded(
            child: ValueListenableBuilder<List<FoodListing>>(
              valueListenable: FoodListing.foodListNotifier,
              builder: (context, allListings, child) {
                final filteredListings = _filterListings(allListings, _searchController.text);
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
      decoration: BoxDecoration(
        color: primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FoodSaver',
            style: GoogleFonts.nunito(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          Text(
            "Don't Waste It. Share It.",
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9), 
            ),
          ),
          const SizedBox(height: 20),
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
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodItemScreen(foodData: item),
          ),
        );
      },
      child: Container(
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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    // Velasquez: Eto yung magic conditional rendering natin!
                    // Kung may imageBytes, gamitin ang Image.memory. Kung wala, Image.asset.
                    child: item.imageBytes != null 
                      ? Image.memory(
                          item.imageBytes!,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          item.offlineImage,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                  ),
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
                ],
              ),
              const SizedBox(width: 16),
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
                        const CircleAvatar(
                          radius: 10, 
                          backgroundImage: AssetImage('assets/images/oranges.png'),
                        ),
                        const SizedBox(width: 6),
                        Text(item.posterAlias, style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildTag('3 hours', const Color(0xFFFFF4EC), Colors.orange),
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
