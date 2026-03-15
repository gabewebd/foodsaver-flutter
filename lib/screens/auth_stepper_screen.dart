import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/supabase_service.dart';

// Velasquez: Updated ito! 2 steps na lang tayo para di tamarin yung user. 
// Tinanggal na natin yung Avatar Picker dahil automatic na DiceBear, iwas buggy uploads.
class AuthStepperScreen extends StatefulWidget {
  final VoidCallback onLoginInstead;
  const AuthStepperScreen({super.key, required this.onLoginInstead});

  @override
  State<AuthStepperScreen> createState() => _AuthStepperScreenState();
}

class _AuthStepperScreenState extends State<AuthStepperScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Controllers para sa Step 1
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Controllers para sa Step 2
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _buildingController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Velasquez, ito yung finale! Gagamit na tayo ng registerCustomUser.
  Future<void> _completeSetup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final fullName = _fullNameController.text.trim();
    final building = _buildingController.text.trim();

    if (fullName.isEmpty || building.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in your name and building.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Velasquez: Direct database insert na 'to pre, wag niyo na balikan yung logic.
    // Yamzon, paki-double check if may redundant entries sa profiles table.
    final error = await SupabaseService.registerCustomUser(
      email,
      password,
      fullName,
      building,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      // Success! Move to Home Feed via AuthGate logic.
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildProgressIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), 
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                    ],
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator(color: Color(0xFF0F9D58))),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(2, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: _currentPage == index ? 24 : 8,
            decoration: BoxDecoration(
              color: _currentPage == index ? const Color(0xFF0F9D58) : const Color(0xFFE65100).withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContainer(String title, String subtitle, List<Widget> children) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, 
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFFE65100))),
            const SizedBox(height: 8),
            Text(subtitle, 
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(children: children),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: widget.onLoginInstead,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Already have an account? ",
                  style: GoogleFonts.nunito(color: Colors.grey[600]),
                  children: [
                    TextSpan(
                      text: "Log In",
                      style: GoogleFonts.nunito(
                        color: const Color(0xFFE65100),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return _buildStepContainer(
      'Join FoodSaver.',
      'Start sharing and saving food in your local community today.',
      [
        _buildTextField(controller: _emailController, hint: 'Email Address', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildTextField(controller: _passwordController, hint: 'Password', icon: Icons.lock_outline, obscureText: true),
        const SizedBox(height: 32),
        _buildButton(
          label: 'Next',
          color: const Color(0xFF0F9D58), // Mixed: Green Next
          onPressed: () {
            if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
              _nextPage();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter email and password.')));
            }
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return _buildStepContainer(
      'Who are you?',
      'Let your community know who they are picking up from.',
      [
        _buildTextField(controller: _fullNameController, hint: 'Full Name (e.g., Mika Yamaguchi)', icon: Icons.person_outline),
        const SizedBox(height: 16),
        _buildTextField(controller: _buildingController, hint: 'Building / Location', icon: Icons.location_city_outlined),
        const SizedBox(height: 32),
        Row(
          children: [
            IconButton(
              onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildButton(
                label: 'Complete Setup',
                color: const Color(0xFFE65100), // Mixed: Orange Setup
                onPressed: _completeSetup,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.nunito(fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          hintText: hint,
          hintStyle: GoogleFonts.nunito(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildButton({required String label, required Color color, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800)),
      ),
    );
  }
}
