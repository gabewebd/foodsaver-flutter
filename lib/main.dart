import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'screens/home_feed_screen.dart';
import 'screens/share_food_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/sustainability_hub_screen.dart';

// Yamzon, nilagay ko na 'to dito kasi pag nag-add tayo ng 
// camera or local storage packages later, we will need this initialized.
// Wag mo na galawin 'to paps para iwas error sa build natin!
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FoodSaverCoreApp());
}

// Camus, extract natin yung colors sa labas para madali i-edit mo later
// kung may papalitan ka sa branding ng FoodSaver natin. 
const _brandGreen = Color(0xFF0F9D58); 
const _accentOrange = Color(0xFFF57C00);
const _canvasOffWhite = Color(0xFFF5F7F5); // Linis tignan para di cluttered yung UI, diba?

class FoodSaverCoreApp extends StatelessWidget {
  const FoodSaverCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tinanggal ko 'to para malinis tignan pag prinesent natin.
      title: 'FoodSaver MVP',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _canvasOffWhite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _brandGreen, 
          primary: _brandGreen,
          secondary: _accentOrange, 
        ),
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: MainShellCoordinator(), // Tinanggal ko yung const dahil sa Notifier natin
    );
  }
}

// Ginamit nating StatelessWidget imbes na Stateful para tipid sa memory.
class MainShellCoordinator extends StatelessWidget {
  MainShellCoordinator({super.key});

  // Structural change: ValueNotifier imbes na setState()
  // Velasquez, ito yung mag-hahandle ng state nang mas malinis at mas mabilis.
  // Less rebuilds = tipid sa resources at iwas lag sa mga phone natin!
  final ValueNotifier<int> _navController = ValueNotifier<int>(0);

  // Aguiluz, Velasquez, Yamaguchi, Camus, Yamzon -- dito naka-plug yung mga actual screens niyo.
  // Make sure same yung pangalan ng classes niyo dito sa ini-import natin sa taas ha!
  final List<Widget> _injectedScreens = const [
    HomeFeedScreen(),        // Index 0: Taps to "Home" (Aguiluz)
    ShareFoodScreen(),       // Index 1: Taps to "Post" (Velasquez)
    AlertsScreen(),          // Index 2: Taps to "Alerts" (Yamaguchi)
    SustainabilityHubScreen()// Index 3: Taps to "Profile" (Camus)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Aguiluz, nilipat ko yung main header sa HomeFeedScreen para di mag-doble sa ibang screens.
      // Velasquez, check mo 'tong Scaffold natin, wala na siyang global AppBar. Kanya-kanyang header na tayo per tab.
      body: ValueListenableBuilder<int>(
        valueListenable: _navController,
        builder: (context, activeIndex, child) {
          return _injectedScreens[activeIndex];
        },
      ),
      bottomNavigationBar: _assembleBottomRouting(),
    );
  }

  // Yamzon, binalot din natin yung BottomNav sa sarili niyang builder para ito lang nag-uupdate pag nag-switch tab.
  Widget _assembleBottomRouting() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: _navController,
        builder: (context, activeIndex, child) {
          return BottomNavigationBar(
            currentIndex: activeIndex,
            // Imbes na setState, update lang natin yung value ng notifier. Mas efficient 'to mga paps.
            onTap: (index) => _navController.value = index,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: _brandGreen,
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: true,
            showUnselectedLabels: true, 
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined),
                activeIcon: Icon(Icons.add_box),
                label: 'Post',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                activeIcon: Icon(Icons.notifications),
                label: 'Alerts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}