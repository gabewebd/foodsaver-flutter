import 'package:flutter/material.dart';

class Months {
  static const List<String> full = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  static const List<String> short = [
    'Jan.', 'Feb.', 'Mar.', 'Apr.', 'May', 'Jun.', 'Jul.', 'Aug.', 'Sep.', 'Oct.', 'Nov.', 'Dec.'
  ];
}

class TimeUtils {
  static String getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown time';
    
    // Ensure we are comparing UTC to UTC or Local to Local
    final now = DateTime.now();
    final difference = now.difference(dateTime.toLocal());
    
    if (difference.isNegative) return 'Just now'; // Handle clock skew
    if (difference.inDays >= 365) return '${(difference.inDays / 365).floor()}y ago';
    if (difference.inDays >= 30) return '${(difference.inDays / 30).floor()}mo ago';
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  static (String, Color) getExpiresIn(DateTime? expiryDate) {
    if (expiryDate == null) return ('Flexible Expiry', const Color(0xFF0F9D58)); // Green
    
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    
    if (difference.isNegative) return ('Expired', Colors.red);
    
    if (difference.inHours > 72) {
      return ('Expires in ${difference.inDays}d', const Color(0xFF0F9D58)); // Green
    } else if (difference.inHours > 24) {
      return ('Expires in ${difference.inDays}d', Colors.orange); // Yellow/Orange
    } else if (difference.inHours > 0) {
      return ('Expires in ${difference.inHours}h', Colors.red); // Red
    } else if (difference.inMinutes > 0) {
      return ('Expires in ${difference.inMinutes}m', Colors.red); // Red
    }
    
    return ('Expires soon', Colors.red);
  }

  static String formatFullDate(DateTime? date) {
    if (date == null) return 'No date';
    return '${Months.full[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String formatShortDate(DateTime? date) {
    if (date == null) return 'No date';
    return '${Months.short[date.month - 1]} ${date.day}, ${date.year}';
  }
}
