import 'package:flutter/material.dart';
import 'auth_screen.dart';
import '../main.dart'; 
import '../data/supabase_service.dart';

// Velasquez: Updated bouncer na tayo pre! 
// Hindi na tayo nakadepende sa Supabase Auth state, masyadong mabagal.
// Tinitignan na lang natin kung may 'foodsaver_user_id' sa local storage para instant pasok.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkLocalSession();
  }

  // Mark Dave, dito natin chine-check yung local session. 
  // Wag mong galawin shared_preferences config natin pre.
  Future<void> _checkLocalSession() async {
    await SupabaseService.initSession();
    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0F9D58)),
        ),
      );
    }

    // Using custom local session ID instead of auth.session.
    if (SupabaseService.currentUserId != null) {
      // Velasquez, may ID na! Pasok na sa main screens.
      return MainShellCoordinator(); 
    } else {
      // Walang session, balik sa login/register.
      return const AuthScreen();
    }
  }
}
