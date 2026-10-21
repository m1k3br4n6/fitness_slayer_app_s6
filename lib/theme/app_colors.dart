import 'package:flutter/material.dart';

// TODO: Convert static const fields into getters referencing active ThemeController palette.
// TODO: Map both standard aliases and hearth/slate aliases into active ThemePalette instance.
/// Centralized color palette based off a fantasy/pixelated palette
/// To change app colors, update the hex codes below.
class AppColors {
  // Backdrop, Panels & Frames
  // Use slateBackdrop for screen backgrounds
  // TODO: Update slateBackdrop getter to return active palette slateBackdrop value.
  static const Color slateBackdrop = Color(0xFF1F150E);   // Darker brown-orangey hearth backdrop

  // Use hearthPanel for AppBars, Cards, and main container surfaces
  // TODO: Update hearthPanel getter to return active palette hearthPanel value.
  static const Color hearthPanel = Color(0xFF4A3322);     // Panels, Cards, AppBars & Containers
  // TODO: Update woodFrame getter to return active palette woodFrame value.
  static const Color woodFrame = Color(0xFF8A5A33);       // Inner container frames & active borders
  // TODO: Update brassBorder getter to return active palette brassBorder value.
  static const Color brassBorder = Color(0xFFB08A5F);     // Subtle borders & muted secondary text
  // TODO: Update parchmentWhite getter to return active palette parchmentWhite value.
  static const Color parchmentWhite = Color(0xFFE9DCC0);  // Primary text & headings

  // Buttons & Gem Accents
  // Use flameOrange for FABs, main CTA buttons, and flame highlights
  // TODO: Update flameOrange getter to return active palette flameOrange value.
  static const Color flameOrange = Color(0xFFD9541E);     // Primary action buttons & FABs

  // Use gemGold for coins, XP progress bars, level badges, and gem icons
  // TODO: Update gemGold getter to return active palette gemGold value.
  static const Color gemGold = Color(0xFFE8A92C);         // Gem accents, Coins, XP & Level badges

  // Use crimsonRed for cancel/delete actions and active navbar indicators
  // TODO: Update crimsonRed getter to return active palette crimsonRed value.
  static const Color crimsonRed = Color(0xFFA82E2E);      // Secondary alert & cancel actions

  // Standard Structural Aliases
  // TODO: Update structural alias getters to forward to active ThemePalette fields.
  static const Color background = Color(0xFF1F150E);
  static const Color surface = Color(0xFF4A3322);
  static const Color container = Color(0xFF8A5A33);
  static const Color primary = Color(0xFFD9541E);
  static const Color secondary = Color(0xFFA82E2E);
  static const Color gold = Color(0xFFE8A92C);
  static const Color textPrimary = Color(0xFFE9DCC0);
  static const Color textSecondary = Color(0xFFB08A5F);
  static const Color textMuted = Color(0xFF8E8272);
  static const Color border = Color(0xFFB08A5F);

  static const Color obsidianBlack = Color(0xFF1F150E);
  static const Color ashenCharcoal = Color(0xFF1F150E);
  static const Color darkTavernGreen = Color(0xFF4A3322);
  static const Color forgeSlate = Color(0xFF4A3322);
  static const Color deepHearthGreen = Color(0xFF8A5A33);
  static const Color hearthStone = Color(0xFF8A5A33);
  static const Color emberOrange = Color(0xFFD9541E);
  static const Color crimsonWine = Color(0xFFA82E2E);
  static const Color rpgGold = Color(0xFFE8A92C);
  static const Color questGold = Color(0xFFE8A92C);
  static const Color warmIvory = Color(0xFFE9DCC0);
  static const Color parchmentBeige = Color(0xFFB08A5F);
  static const Color mutedParchment = Color(0xFFB08A5F);
  static const Color mutedGray = Color(0xFF8E8272);
  static const Color tavernBorder = Color(0xFFB08A5F);
  static const Color hearthBorder = Color(0xFFB08A5F);
}
