import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Velasquez: Mga pre, ginawa ko tong reusable widget para hindi kalat yung code natin sa screens.
// Paki-style na lang kung may mas premium pa kayong naisip team.
class WittyOfflineBanner extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;

  const WittyOfflineBanner({
    super.key,
    required this.onRetry,
    this.message,
  });

  // Velasquez: Team, paki-siguradong hindi to mag-iinfinite loop mga pre pag pinindot yung retry.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(20),
        // Velasquez: Subtle border lang pre para malinis tignan, wag mo na lagyan ng shadow.
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // Velasquez: Aguiluz, paki-check if maayos yung alignment sa small screens pre.
        children: [
          const Icon(Icons.signal_wifi_off_rounded, color: Colors.red, size: 40),
          const SizedBox(height: 12),
          // Velasquez: Team, ito na yung witty offline message na gusto niyo mga pre.
          // Fresh na fresh para sa user feedback natin!
          Text(
            "Oh no! Your connection is past its expiration date",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800, // Velasquez: Extra bold para dama yung "Oh no!"
              color: Colors.red[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message ?? "You're currently offline. We'll show you what we can, but live updates are on a snack break.",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.red[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          // Velasquez: Itong refresh button pre, paki-check if gumagana lahat ng callbacks.
          const SizedBox(height: 16),
          // Velasquez: Spacing is key pre, wag mong dikit-dikit.
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text("Try Reconnecting"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[100],
              foregroundColor: Colors.red[900],
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
