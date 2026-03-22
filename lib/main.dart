import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'screens/auth_gate.dart';
import 'screens/home_feed_screen.dart';
import 'screens/share_food_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/sustainability_hub_screen.dart';
import 'data/supabase_service.dart';
import 'models/alert_listing.dart';

// Velasquez: Kulay ng FoodSaver, wag niyo na palitan pre.
const brandGreen = Color(0xFF0F9D58); 
const accentOrange = Color(0xFFF57C00);
const canvasOffWhite = Color(0xFFF5F7F5);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
    
    // Velasquez: Initialize natin 'tong session management. 
    // Yamzon, paki-test 'to kung nag-se-save talaga yung user_id.
    await SupabaseService.initSession();
    
    runApp(const FoodSaverCoreApp());
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "Initialization Error: $e",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    ));
  }
}

class FoodSaverCoreApp extends StatelessWidget {
  const FoodSaverCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodSaver MVP',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: canvasOffWhite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandGreen, 
          primary: brandGreen,
          secondary: accentOrange, 
        ),
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const AuthGate(), 
    );
  }
}

class MainShellCoordinator extends StatefulWidget {
  const MainShellCoordinator({super.key});

  // Velasquez: Static method para pwede nating tawagin kahit saan sa app yung pag-switch ng tab.
  static void setTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainShellCoordinatorState>();
    state?._setTab(index);
  }

  @override
  State<MainShellCoordinator> createState() => _MainShellCoordinatorState();
}

class _MainShellCoordinatorState extends State<MainShellCoordinator> {
  final ValueNotifier<int> _navController = ValueNotifier<int>(0);

  void _setTab(int index) {
    _navController.value = index;
  }

  final List<Widget> _injectedScreens = const [
    HomeFeedScreen(),
    ShareFoodScreen(),
    AlertsScreen(),
    SustainabilityHubScreen()
  ]; // Velasquez: Dito niyo lang idagdag pag may bagong screen, wag na sa main code.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: _navController,
        builder: (context, activeIndex, child) {
          return _injectedScreens[activeIndex];
        },
      ),
      bottomNavigationBar: _assembleBottomRouting(),
    );
  }

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
            onTap: (index) => _navController.value = index,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: brandGreen,
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined),
                activeIcon: Icon(Icons.add_box),
                label: 'Post',
              ),
              BottomNavigationBarItem(
                icon: StreamBuilder<List<AlertListing>>(
                  stream: SupabaseService.getAlertsStream(),
                  builder: (context, snapshot) {
                    final unreadCount = snapshot.hasData
                        ? snapshot.data!.where((a) => a.isNew).length
                        : 0;
                    return Badge(
                      isLabelVisible: unreadCount > 0,
                      label: Text(unreadCount.toString()),
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.notifications_outlined),
                    );
                  },
                ),
                activeIcon: const Icon(Icons.notifications),
                label: 'Alerts',
              ),
              const BottomNavigationBarItem(
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
