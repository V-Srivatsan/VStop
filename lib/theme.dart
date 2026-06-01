import 'package:flutter/material.dart';

// ── Palette ──────────────────────────────────────────────────────────────────

class VStopColors {
  VStopColors._();

  // Dark
  static const darkBackground    = Color(0xFF0D1F1F);
  static const darkDialog        = Color(0xFF0F2626);
  static const darkSurface       = Color(0xFF132C2C);
  static const darkTeal          = Color(0xFF2EBFA5);
  static const darkAmber         = Color(0xFFF4A442);
  static const darkTextPrimary   = Color(0xFFF0F4F4);
  static const darkTextSecondary = Color(0xFF7FA8A8);
  static const darkSuccess       = Color(0xFF4CAF82);
  static const darkWarning       = Color(0xFFE05C5C);

  // AMOLED
  static const amoledBackground    = Color(0xFF000000);
  static const amoledDialog        = Color(0xFF0D0D0D);
  static const amoledSurface       = Color(0xFF0A0A0A);
  static const amoledSurfaceVar    = Color(0xFF111111);
  static const amoledCardHighlight = Color(0xFF0D1A1A);

  // Light
  static const lightBackground    = Color(0xFFF2F7F7);
  static const lightDialog        = Color(0xFFE8F0F0);
  static const lightSurface       = Color(0xFFFFFFFF);
  static const lightTeal          = Color(0xFF1A9B85);
  static const lightAmber         = Color(0xFFE8922A);
  static const lightTextPrimary   = Color(0xFF0D1F1F);
  static const lightTextSecondary = Color(0xFF5A7A7A);
  static const lightSuccess       = Color(0xFF3A9E6E);
  static const lightWarning       = Color(0xFFD94F4F);
}

// ── Text Themes ───────────────────────────────────────────────────────────────

TextTheme _buildTextTheme(Color primary, Color secondary) {
  return TextTheme(
    // Screen titles / hero headings
    displayLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 40,
      fontWeight: FontWeight.w700,
      color: primary,
      letterSpacing: -0.5,
    ),
    // Section headings
    headlineMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: primary,
      letterSpacing: -0.3,
    ),
    // Card titles
    titleLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: primary,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: primary,
    ),
    // Section labels (uppercase)
    labelLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: secondary,
      letterSpacing: 0.8,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: secondary,
      letterSpacing: 0.6,
    ),
    // Body
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: primary,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: secondary,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: secondary,
    ),
  );
}

// ── Shared shape ──────────────────────────────────────────────────────────────

const _cardShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(18)),
);

const _inputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(14)),
  borderSide: BorderSide.none,
);

// ── Dark Theme ────────────────────────────────────────────────────────────────

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'Inter',
  
  colorScheme: const ColorScheme.dark(
    surface:          VStopColors.darkSurface,
    primary:          VStopColors.darkTeal,
    secondary:        VStopColors.darkAmber,
    onSurface:        VStopColors.darkTextPrimary,
    onPrimary:        VStopColors.darkBackground,
    onSecondary:      VStopColors.darkBackground,
    error:            VStopColors.darkWarning,
    onError:          VStopColors.darkTextPrimary,
    tertiary:         VStopColors.darkSuccess,
    onSurfaceVariant: VStopColors.darkTextSecondary,
  ),

  scaffoldBackgroundColor: VStopColors.darkBackground,

  textTheme: _buildTextTheme(
    VStopColors.darkTextPrimary,
    VStopColors.darkTextSecondary,
  ),

  cardTheme: CardThemeData(
    color: VStopColors.darkSurface,
    elevation: 0,
    shape: _cardShape,
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    shadowColor: Colors.black.withAlpha(76),
    clipBehavior: .hardEdge
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: VStopColors.darkBackground,
    foregroundColor: VStopColors.darkTextPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: VStopColors.darkTextPrimary,
    ),
    iconTheme: IconThemeData(color: VStopColors.darkTextPrimary),
    actionsIconTheme: IconThemeData(color: VStopColors.darkAmber),
    actionsPadding: .only(right: 10),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: VStopColors.darkSurface,
      elevation: 8,
      unselectedItemColor: VStopColors.darkTeal,
      selectedItemColor: VStopColors.darkAmber
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: VStopColors.darkDialog
  ),

  bottomSheetTheme: BottomSheetThemeData(
    showDragHandle: true, modalBarrierColor: Colors.black.withAlpha(128),
    backgroundColor: VStopColors.darkDialog
  ),

  drawerTheme: const DrawerThemeData(
    backgroundColor: VStopColors.darkSurface,
    elevation: 16,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: VStopColors.darkAmber,
      foregroundColor: VStopColors.darkBackground,
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: VStopColors.darkTeal,
      side: const BorderSide(color: VStopColors.darkTeal, width: 1.5),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: VStopColors.darkAmber,
    foregroundColor: VStopColors.darkBackground,
    shape: StadiumBorder(),
    elevation: 4,
  ),

  progressIndicatorTheme: ProgressIndicatorThemeData(
      color: VStopColors.darkAmber,
      linearTrackColor: VStopColors.darkSurface
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: VStopColors.darkSurface,
    border: _inputBorder,
    enabledBorder: _inputBorder,
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: const BorderSide(color: VStopColors.darkTeal, width: 1.5),
    ),
    hintStyle: const TextStyle(
      color: VStopColors.darkTextSecondary,
      fontFamily: 'Inter',
      fontSize: 14,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  ),

  tabBarTheme: const TabBarThemeData(
    labelColor: VStopColors.darkAmber,
    unselectedLabelColor: VStopColors.darkTeal,
    indicatorColor: VStopColors.darkAmber,
    indicatorSize: TabBarIndicatorSize.tab,
    dividerColor: Colors.transparent,
    labelStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: VStopColors.darkSurface,
    selectedColor: VStopColors.darkTeal.withAlpha(51),
    labelStyle: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      color: VStopColors.darkTextPrimary,
    ),
    side: BorderSide.none,
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),

  dividerTheme: const DividerThemeData(
    color: Color(0xFF1E3E3E),
    thickness: 1,
    space: 1,
  ),

  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    textColor: VStopColors.darkTextPrimary,
    iconColor: VStopColors.darkTeal,
  ),
);

// ── AMOLED Theme ───────────────────────────────────────────────────────────────

final amoledTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'Inter',

  colorScheme: const ColorScheme.dark(
    surface:          VStopColors.amoledSurface,
    primary:          VStopColors.darkTeal,
    secondary:        VStopColors.darkAmber,
    onSurface:        VStopColors.darkTextPrimary,
    onPrimary:        VStopColors.amoledBackground,
    onSecondary:      VStopColors.amoledBackground,
    error:            VStopColors.darkWarning,
    onError:          VStopColors.darkTextPrimary,
    tertiary:         VStopColors.darkSuccess,
    onSurfaceVariant: VStopColors.darkTextSecondary,
  ),

  scaffoldBackgroundColor: VStopColors.amoledBackground,

  textTheme: _buildTextTheme(
    VStopColors.darkTextPrimary,
    VStopColors.darkTextSecondary,
  ),

  cardTheme: CardThemeData(
    color: VStopColors.amoledCardHighlight,
    elevation: 0,
    shape: _cardShape,
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    shadowColor: Colors.transparent, // no shadow on AMOLED — pointless on black
    clipBehavior: .hardEdge
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: VStopColors.amoledBackground,
    foregroundColor: VStopColors.darkTextPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: VStopColors.darkTextPrimary,
    ),
    iconTheme: IconThemeData(color: VStopColors.darkTextPrimary),
    actionsIconTheme: IconThemeData(color: VStopColors.darkAmber),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: VStopColors.amoledSurface,
      elevation: 8,
      unselectedItemColor: VStopColors.darkTeal,
      selectedItemColor: VStopColors.darkAmber
  ),

  dialogTheme: DialogThemeData(
      backgroundColor: VStopColors.amoledDialog
  ),

  bottomSheetTheme: BottomSheetThemeData(
      showDragHandle: true, modalBarrierColor: Colors.black.withAlpha(128),
      backgroundColor: VStopColors.amoledDialog
  ),

  drawerTheme: const DrawerThemeData(
    backgroundColor: VStopColors.amoledSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: VStopColors.darkAmber,
      foregroundColor: VStopColors.amoledBackground,
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: VStopColors.darkTeal,
      side: const BorderSide(color: VStopColors.darkTeal, width: 1.5),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: VStopColors.darkAmber,
    foregroundColor: VStopColors.amoledBackground,
    shape: StadiumBorder(),
    elevation: 0,
  ),

  progressIndicatorTheme: ProgressIndicatorThemeData(
      color: VStopColors.darkAmber,
      linearTrackColor: VStopColors.amoledSurface
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: VStopColors.amoledSurface,
    border: _inputBorder,
    enabledBorder: _inputBorder,
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: const BorderSide(color: VStopColors.darkTeal, width: 1.5),
    ),
    hintStyle: const TextStyle(
      color: VStopColors.darkTextSecondary,
      fontFamily: 'Inter',
      fontSize: 14,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  ),

  tabBarTheme: TabBarThemeData(
    labelColor: VStopColors.darkAmber,
    unselectedLabelColor: VStopColors.darkTeal,
    indicatorColor: VStopColors.darkAmber,
    indicatorSize: TabBarIndicatorSize.tab,
    indicator: BoxDecoration(
      color: VStopColors.darkTeal.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    dividerColor: Colors.transparent,
    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    labelStyle: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: VStopColors.amoledSurface,
    selectedColor: VStopColors.darkTeal.withOpacity(0.2),
    labelStyle: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      color: VStopColors.darkTextPrimary,
    ),
    side: BorderSide.none,
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),

  dividerTheme: const DividerThemeData(
    color: Color(0xFF252525),
    thickness: 1,
    space: 1,
  ),

  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    textColor: VStopColors.darkTextPrimary,
    iconColor: VStopColors.darkTeal,
  ),
);

// ── Light Theme ───────────────────────────────────────────────────────────────

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Inter',

  colorScheme: const ColorScheme.light(
    surface:          VStopColors.lightSurface,
    primary:          VStopColors.lightTeal,
    secondary:        VStopColors.lightAmber,
    onSurface:        VStopColors.lightTextPrimary,
    onPrimary:        VStopColors.lightSurface,
    onSecondary:      VStopColors.lightSurface,
    error:            VStopColors.lightWarning,
    onError:          VStopColors.lightSurface,
    tertiary:         VStopColors.lightSuccess,
    onSurfaceVariant: VStopColors.lightTextSecondary,
  ),

  scaffoldBackgroundColor: VStopColors.lightBackground,

  textTheme: _buildTextTheme(
    VStopColors.lightTextPrimary,
    VStopColors.lightTextSecondary,
  ),

  cardTheme: CardThemeData(
    color: VStopColors.lightSurface,
    elevation: 2,
    shape: _cardShape,
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    shadowColor: const Color(0xFF0D1F1F).withAlpha(20),
    clipBehavior: .hardEdge
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: VStopColors.lightBackground,
    foregroundColor: VStopColors.lightTextPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: VStopColors.lightTextPrimary,
    ),
    iconTheme: IconThemeData(color: VStopColors.lightTextPrimary),
    actionsIconTheme: IconThemeData(color: VStopColors.lightAmber),
    actionsPadding: .only(right: 10),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: VStopColors.lightSurface,
    elevation: 8,
    unselectedItemColor: VStopColors.lightTeal,
    selectedItemColor: VStopColors.lightAmber
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: VStopColors.lightDialog
  ),

  bottomSheetTheme: BottomSheetThemeData(
    showDragHandle: true, modalBarrierColor: Colors.black.withAlpha(128),
    backgroundColor: VStopColors.lightDialog
  ),

  drawerTheme: const DrawerThemeData(
    backgroundColor: VStopColors.lightSurface,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: VStopColors.lightAmber,
      foregroundColor: VStopColors.lightSurface,
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: VStopColors.lightTeal,
      side: const BorderSide(color: VStopColors.lightTeal, width: 1.5),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: VStopColors.lightAmber,
    foregroundColor: VStopColors.lightSurface,
    shape: StadiumBorder(),
    elevation: 4,
  ),

  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: VStopColors.lightAmber,
    linearTrackColor: VStopColors.lightSurface
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: VStopColors.lightSurface,
    border: _inputBorder,
    enabledBorder: _inputBorder,
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: const BorderSide(color: VStopColors.lightTeal, width: 1.5),
    ),
    hintStyle: const TextStyle(
      color: VStopColors.lightTextSecondary,
      fontFamily: 'Inter',
      fontSize: 14,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  ),

  tabBarTheme: const TabBarThemeData(
    labelColor: VStopColors.lightAmber,
    unselectedLabelColor: VStopColors.lightTeal,
    indicatorColor: VStopColors.lightAmber,
    indicatorSize: TabBarIndicatorSize.tab,
    labelStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: VStopColors.lightBackground,
    selectedColor: VStopColors.lightTeal.withAlpha(38),
    labelStyle: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      color: VStopColors.lightTextPrimary,
    ),
    side: BorderSide.none,
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),

  dividerTheme: const DividerThemeData(
    color: Color(0xFFDCE8E8),
    thickness: 1,
    space: 1,
  ),

  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    textColor: VStopColors.lightTextPrimary,
    iconColor: VStopColors.lightTeal,
  ),
);