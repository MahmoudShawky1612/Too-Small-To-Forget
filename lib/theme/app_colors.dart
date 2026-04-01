// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // ─── Core Backgrounds ───────────────────────────────────────────
  /// Deepest layer — scaffold, screen backgrounds
  static const Color background = Color(0xFF120B06);

  /// Second layer — bottom nav, app bar surfaces
  static const Color surface = Color(0xFF1E1209);

  /// Third layer — input fields, tiles, list items
  static const Color surfaceElevated = Color(0xFF2A1C10);

  /// Subtle dividers / borders
  static const Color border = Color(0xFF3D2819);

  // ─── Memory Cards ───────────────────────────────────────────────
  /// Warm cream — light card face
  static const Color cardBackground = Color(0xFFF5EBE0);

  /// Slightly darker cream for card hover / pressed states
  static const Color cardBackgroundPressed = Color(0xFFECDDD1);

  /// Soft warm stroke around cream cards
  static const Color cardBorder = Color(0xFFD9C3B0);

  // ─── Primary Accent (Terracotta) ────────────────────────────────
  /// Main CTA, FAB, selected chips
  static const Color primary = Color(0xFFBF5533);

  /// Hover / pressed state of primary
  static const Color primaryDark = Color(0xFFA84729);

  /// Very subtle primary tint for backgrounds (pill badge bg, etc.)
  static const Color primaryMuted = Color(0x1FBF5533); // ~12% opacity

  // ─── Secondary Accent (Warm Amber) ──────────────────────────────
  /// Reminder badge, highlights
  static const Color amber = Color(0xFFD4913A);

  /// Muted amber tint
  static const Color amberMuted = Color(0x1FD4913A);

  // ─── Text — on DARK surfaces ────────────────────────────────────
  /// High-emphasis on dark bg  (app title, card headers)
  static const Color textLight = Color(0xFFF5EBE0);

  /// Medium-emphasis on dark bg (labels, sub-headers)
  static const Color textMid = Color(0xFFCFB49A);

  /// Low-emphasis on dark bg (hints, placeholders, timestamps)
  static const Color textMuted = Color(0xFF8C6F58);

  // ─── Text — on LIGHT (cream card) surfaces ──────────────────────
  /// High-emphasis on cream cards
  static const Color textPrimary = Color(0xFF1E1209);

  /// Medium-emphasis on cream cards (details, description)
  static const Color textSecondary = Color(0xFF6B5244);

  /// Low-emphasis on cream cards (date, tiny labels)
  static const Color textTertiary = Color(0xFF9E7E6B);

  // ─── Semantic ───────────────────────────────────────────────────
  static const Color danger = Color(0xFFBF3030);
  static const Color dangerMuted = Color(0x1FBF3030);
  static const Color success = Color(0xFF3D8C5C);

  // ─── Chip states (convenience) ──────────────────────────────────
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
    colors: [Color(0xFFF8EFE4), Color(0xFFEFDFCF)],
  );
}