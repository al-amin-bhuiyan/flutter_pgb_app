import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0D9488);
  static const Color textPrimary = Color(0xFF131A24);
  static const Color textSecondary = Color(0xFF5C6675);
  static const Color textLight = Color(0xFF6B7480);
  static const Color background = Color(0xFFEBEDF1);
  static const Color cardBackground = Color(0xFFF4F6F8);
  static const Color border = Color(0xFFE6EAEF);
  static const Color tealLight = Color(0xFFD6F3EF);
  static const Color white = Colors.white;
  static const Color error = Colors.redAccent;

  // Figma Dynamic Theme Colors
  static Color outerCard(bool isDark) => isDark ? const Color(0xFF0E1521) : const Color(0xFFF4F6F8);
  static Color cardBorder(bool isDark) => isDark ? const Color(0xFF222C3A) : const Color(0xFFE6EAEF);
  static Color inputBackground(bool isDark) => isDark ? const Color(0xFF18212F) : Colors.white;
  static Color inputBorder(bool isDark) => isDark ? const Color(0xFF283446) : const Color(0xFFE6EAEF);
  static Color accent(bool isDark) => isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488);
  static Color title(bool isDark) => isDark ? const Color(0xFFEEF2F7) : const Color(0xFF131A24);
  static Color subtitle(bool isDark) => isDark ? const Color(0xFF98A4B4) : const Color(0xFF5C6675);
  static Color shadow(bool isDark) => isDark ? const Color(0x66000000) : const Color(0x1E19202D);
  static Color focusHighlight(bool isDark) => isDark ? const Color(0xFF2DD4BF).withOpacity(0.15) : const Color(0xFFD6F3EF);
}
