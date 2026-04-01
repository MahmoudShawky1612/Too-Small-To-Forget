import 'package:flutter/material.dart';

class AppColors {
  // ─── Core Backgrounds ───────────────────────────────────────────
  static const Color background = Color(0xFF120B06);
  static const Color surface = Color(0xFF1E1209);
  static const Color surfaceElevated = Color(0xFF2A1C10);
  static const Color border = Color(0xFF3D2819);

  // ─── Memory Cards ───────────────────────────────────────────────
  /// Dark warm brown card face
  static const Color cardBackground = Color(0xFF3A2A20);

  /// Slightly darker pressed state
  static const Color cardBackgroundPressed = Color(0xFF2F221A);

  /// Softer border that blends into the dark card
  static const Color cardBorder = Color(0xFF5A4333);

  // ─── Primary Accent (Terracotta) ────────────────────────────────
  static const Color primary = Color(0xFFBF5533);
  static const Color primaryDark = Color(0xFFA84729);
  static const Color primaryMuted = Color(0x1FBF5533);

  // ─── Secondary Accent (Warm Amber) ──────────────────────────────
  static const Color amber = Color(0xFFD4913A);
  static const Color amberMuted = Color(0x1FD4913A);

  // ─── Text — on DARK surfaces ────────────────────────────────────
  static const Color textLight = Color(0xFFF5EBE0);
  static const Color textMid = Color(0xFFCFB49A);
  static const Color textMuted = Color(0xFF8C6F58);

  // ─── Text — on Memory Cards ─────────────────────────────────────
  static const Color textPrimary = Color(0xFFF3E4D7);
  static const Color textSecondary = Color(0xFFD0B7A2);
  static const Color textTertiary = Color(0xFFA98B75);

  // ─── Semantic ───────────────────────────────────────────────────
  static const Color danger = Color(0xFFBF3030);
  static const Color dangerMuted = Color(0x1FBF3030);
  static const Color success = Color(0xFF3D8C5C);

  // ─── Chip states ────────────────────────────────────────────────
  static const Color chipSelected = primary;
  static const Color chipUnselected = surfaceElevated;
  static const Color chipSelectedText = Color(0xFFF5EBE0);
  static const Color chipUnselectedText = textMid;

  // ─── Gradient helpers ───────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A0E07), Color(0xFF120B06)],
  );

  static const LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF433126),
      Color(0xFF32241B),
    ],
  );
}