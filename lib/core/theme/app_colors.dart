import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFF0B111D);
  static const surface = Color(0xFF151D2E);
  static const surfaceLight = Color(0xFF1E293B);
  static const card = Color(0xFF1A2332);
  static const border = Color(0xFF2D3748);

  static const gold = Color(0xFFF9B83E);
  static const goldDark = Color(0xFFE5A020);
  static const goldGradientStart = Color(0xFFFDB851);
  static const goldGradientEnd = Color(0xFFF59E0B);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9CA3AF);
  static const textMuted = Color(0xFF6B7280);

  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF60A5FA);

  static const incomingBubble = Color(0xFF21262D);
  static const outgoingBubble = Color(0xFFF9B83E);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldGradientStart, goldGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
