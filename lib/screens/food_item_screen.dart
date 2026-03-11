import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_data.dart';

// Yamzon, dito ko na kinonek yung FoodItemScreen mo.
// Pag kinlick ng user yung card sa Home Feed ni Aguiluz, dito pupunta 'yun.
class FoodItemScreen extends StatelessWidget {
  final FoodListing foodData;

  const FoodItemScreen({super.key, required this.foodData});

  @override
  Widget build(BuildContext context) {
    // Camus, ginawa kong mas specific yung names ng variables dito.
    // Para 'di tayo malito pag may babaguhin tayo sa colors ng FoodSaver theme natin later.
    const Color brandGreen = Color(0xFF0F9D58);
    const Color accentOrange = Color(0xFFF57C00);
    const Color lightGrey = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: brandGreen, 
      body: SafeArea(
        bottom: false, // In-off ko 'to para umabot hanggang ilalim yung puting sheet.
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FoodItemIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      _FoodItemIconButton(
                        // Yamaguchi, i-link mo 'to sa Favorites feature mo pag gumawa na tayo ng database ha?
                        // Placeholder lang muna siya ngayon.
                        icon: Icons.favorite_border,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 12),
                      _FoodItemIconButton(
                        // Pwede natin 'to gamitan ng share_plus package sa susunod na sprint!
                        icon: Icons.share_outlined,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: MediaQuery.of(context).size.height * 0.4,
                    // Velasquez, ito yung conditional rendering natin! 
                    // Eto nag-aayos nung issue natin sa image picking vs mock data assets.
                    child: foodData.imageBytes != null 
                      ? Image.memory(
                          foodData.imageBytes!,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          foodData.offlineImage,
                          fit: BoxFit.cover,
                        ),
                  ),
                  
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2D36).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          // Naka-hardcode muna yung 3 hours. 
                          // Yamzon, compute natin 'to ng maayos pag may date created na sa model natin next week.
                          Text(
                            '3 hours',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.65,
                      minChildSize: 0.65,
                      maxChildSize: 0.95,
                      builder: (context, scrollController) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  foodData.grabTitle,
                                  style: GoogleFonts.nunito(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                Row(
                                  children: [
                                    _StatusBadge(
                                      text: 'Expires Today!',
                                      backgroundColor: const Color(0xFFFFEBEE),
                                      textColor: Colors.red.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    _StatusBadge(
                                      text: 'Available',
                                      backgroundColor: const Color(0xFFE8F5E9),
                                      textColor: brandGreen,
                                      icon: Icons.check_circle_outline,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                
                                Divider(color: Colors.grey.shade200),
                                const SizedBox(height: 16),
                                
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.grey.shade200,
                                      // Default avatar muna habang wala pang profile picture feature
                                      backgroundImage: const AssetImage('assets/images/image.png'),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                foodData.posterAlias,
                                                style: GoogleFonts.nunito(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF1A1A1A),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'Just now',
                                            style: GoogleFonts.nunito(
                                              fontSize: 14,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Divider(color: Colors.grey.shade200),
                                const SizedBox(height: 16),
                                
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: brandGreen.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.location_on_outlined, color: brandGreen),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pickup Location',
                                          style: GoogleFonts.nunito(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                        Text(
                                          foodData.meetupSpot, // Hihilain niya 'to sa mock_data natin
                                          style: GoogleFonts.nunito(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: lightGrey,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Description',
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        foodData.backstory,
                                        style: GoogleFonts.nunito(
                                          fontSize: 15,
                                          height: 1.5,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Aguiluz, pag pinindot 'to, gawa tayo ng push notification para maka-receive
                                      // ng alert yung nag-post doon sa AlertsScreen na hawak ni Yamaguchi.
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Success!'),
                                          content: const Text('You have claimed this item!'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentOrange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.check_circle_outline),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Claim This Item',
                                          style: GoogleFonts.nunito(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Iniba ko name para hindi masyadong generic. Ginamit ko as helper widget para 
// hindi humaba yung code natin sa taas.
class _FoodItemIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _FoodItemIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}

// Same dito, renamed from _Badge to _StatusBadge para klaro kung para saan.
class _StatusBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const _StatusBadge({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.nunito(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}