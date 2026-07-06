import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Helper class for date and time operations
class DateTimeHelper {
  /// Get time-based greeting
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'GOOD MORNING';
    } else if (hour >= 12 && hour < 17) {
      return 'GOOD AFTERNOON';
    } else if (hour >= 17 && hour < 21) {
      return 'GOOD EVENING';
    } else {
      return 'GOOD NIGHT';
    }
  }

  /// Get time-based emoji asset path
  static String getGreetingEmoji() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 17) {
      return 'assets/emojis/sun.png'; // Morning/Afternoon
    } else if (hour >= 17 && hour < 21) {
      return 'assets/emojis/flower.png'; // Evening
    } else {
      return 'assets/emojis/moon.png'; // Night
    }
  }

  /// Format date in a user-friendly way (e.g., "Saturday, 29 March 2026")
  static String getFormattedDate({DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    return DateFormat('EEEE, d MMMM y').format(targetDate);
  }

  /// Format time (e.g., "2:30 PM")
  static String getFormattedTime({DateTime? time}) {
    final targetTime = time ?? DateTime.now();
    return DateFormat('h:mm a').format(targetTime);
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return DateUtils.isSameDay(date, now);
  }

  /// Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return DateUtils.isSameDay(date, yesterday);
  }

  /// Get relative date string (Today, Yesterday, or formatted date)
  static String getRelativeDate(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    return DateFormat('MMM d').format(date);
  }
}
