import 'dart:io';
import 'package:http/http.dart';

// Velasquez: Team, dito ko na nilagay lahat ng error parsing natin para hindi kalat sa UI.
// Stay clean and premium tayo mga pre!
class ErrorUtils {
  static String getFriendlyErrorMessage(Object error) {
    final errorStr = error.toString().toLowerCase();
    
    // Velasquez: Mga pre, paki-check if lahat ng exceptions dito nahuhuli natin, para solid yung offline experience.
    // Check for common network/connectivity exceptions
    if (error is SocketException || 
        errorStr.contains('socketexception') || 
        errorStr.contains('failed host lookup') ||
        errorStr.contains('connection failed') ||
        errorStr.contains('clientfailed to fetch') ||
        errorStr.contains('failed to fetch') ||
        errorStr.contains('handshake_exception')) {
      return "You're currently offline. We'll show you what we can, but live updates are on a snack break.";
    }
    
    // Velasquez: Minsan mabagal talaga internet dito sa atin pre, kaya kailangan tong timeout handling.
    if (errorStr.contains('timeout') || 
        errorStr.contains('deadline exceeded') || 
        errorStr.contains('connection timed out')) {
      return 'Connection timed out. Please try again later.';
    }

    if (errorStr.contains('http status 404')) {
      return 'The requested data was not found.';
    }

    if (errorStr.contains('http status 50')) {
      return 'Server is currently unavailable. Please try again later.';
    }

    // Generic fallback with "Exception: " stripped
    // Velasquez: Default fallback to pre, wag sana natin to makita sa prod.
    return 'Error: ${error.toString().replaceAll('Exception: ', '').trim()}';
  }
}
