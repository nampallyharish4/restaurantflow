import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the restaurant operations application.
class AppTheme {
  AppTheme._();

  // Restaurant-focused color palette
  static const Color primaryLight = Color(0xFFFF6B35); // Energetic orange
  static const Color secondaryLight = Color(0xFF2E86AB); // Professional blue
  static const Color successLight = Color(0xFF06D6A0); // Clear green
  static const Color warningLight = Color(0xFFF18701); // Amber
  static const Color errorLight = Color(0xFFE63946); // Distinct red
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white
  static const Color backgroundLight = Color(0xFFF8F9FA); // Subtle gray
  static const Color onSurfaceLight =
      Color(0xFF212529); // High contrast dark gray
  static const Color onBackgroundLight = Color(0xFF495057); // Medium gray
  static const Color outlineLight = Color(0xFFDEE2E6); // Light gray

  // Dark theme variants
  static const Color primaryDark =
      Color(0xFFFF8A5B); // Lighter orange for dark mode
  static const Color secondaryDark =
      Color(0xFF4A9BC7); // Lighter blue for dark mode
  static const Color successDark =
      Color(0xFF26E5B8); // Lighter green for dark mode
  static const Color warningDark =
      Color(0xFFFFB347); // Lighter amber for dark mode
  static const Color errorDark = Color(0xFFFF6B7A); // Lighter red for dark mode
  static const Color surfaceDark = Color(0xFF1E1E1E); // Dark surface
  static const Color backgroundDark = Color(0xFF121212); // Dark background
  static const Color onSurfaceDark = Color(0xFFE0E0E0); // Light text on dark
  static const Color onBackgroundDark = Color(0xFFB0B0B0); // Medium light text
  static const Color outlineDark = Color(0xFF404040); // Dark outline

  // Card and dialog colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2D2D2D);
  static const Color dialogLight = Color(0xFFFFFFFF);
  static const Color dialogDark = Color(0xFF2D2D2D);

  // Shadow colors with restaurant-appropriate opacity
  static const Color shadowLight = Color(0x1A000000); // 0.1 opacity
  static const Color shadowDark = Color(0x26FFFFFF); // 0.15 opacity

  // Divider colors
  static const Color dividerLight = Color(0xFFDEE2E6);
  static const Color dividerDark = Color(0xFF404040);

  // Text emphasis colors for restaurant operations
  static const Color textHighEmphasisLight = Color(0xFF212529); // 100% opacity
  static const Color textMediumEmphasisLight =
      Color(0xFF495057); // Medium emphasis
  static const Color textDisabledLight = Color(0xFF6C757D); // Disabled state

  static const Color textHighEmphasisDark =
      Color(0xFFE0E0E0); // High emphasis dark
  static const Color textMediumEmphasisDark =
      Color(0xFFB0B0B0); // Medium emphasis dark
  static const Color textDisabledDark = Color(0xFF808080); // Disabled dark

  /// Light theme optimized for restaurant operations
  static ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: primaryLight,
          onPrimary: Colors.white,
          primaryContainer: primaryLight.withValues(alpha: 0.1),
          onPrimaryContainer: primaryLight,
          secondary: secondaryLight,
          onSecondary: Colors.white,
          secondaryContainer: secondaryLight.withValues(alpha: 0.1),
          onSecondaryContainer: secondaryLight,
          tertiary: successLight,
          onTertiary: Colors.white,
          tertiaryContainer: successLight.withValues(alpha: 0.1),
          onTertiaryContainer: successLight,
          error: errorLight,
          onError: Colors.white,
          surface: surfaceLight,
          onSurface: onSurfaceLight,
          onSurfaceVariant: onBackgroundLight,
          outline: outlineLight,
          outlineVariant: outlineLight.withValues(alpha: 0.5),
          shadow: shadowLight,
          scrim: Colors.black54,
          inverseSurface: surfaceDark,
          onInverseSurface: onSurfaceDark,
          inversePrimary: primaryDark),
      scaffoldBackgroundColor: backgroundLight,
      cardColor: cardLight,
      dividerColor: dividerLight,

      // AppBar theme for restaurant operations
      appBarTheme: AppBarTheme(
          backgroundColor: surfaceLight,
          foregroundColor: onSurfaceLight,
          elevation: 2.0,
          shadowColor: shadowLight,
          titleTextStyle: GoogleFonts.inter(
              fontSize: 20, fontWeight: FontWeight.w600, color: onSurfaceLight),
          iconTheme: IconThemeData(color: onSurfaceLight)),

      // Card theme with restaurant-appropriate elevation
      cardTheme: CardTheme(
          color: cardLight,
          elevation: 2.0,
          shadowColor: shadowLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          margin: const EdgeInsets.all(8.0)),

      // Bottom navigation for restaurant staff
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceLight,
          selectedItemColor: primaryLight,
          unselectedItemColor: textMediumEmphasisLight,
          elevation: 8.0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle:
              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle:
              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400)),

      // Floating action button for primary actions
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0))),

      // Button themes optimized for restaurant operations
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primaryLight,
              elevation: 2.0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              side: BorderSide(color: primaryLight, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),

      // Typography system using Inter font
      textTheme: _buildTextTheme(isLight: true),

      // Input decoration for restaurant forms
      inputDecorationTheme: InputDecorationTheme(
          fillColor: surfaceLight,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: outlineLight)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: outlineLight)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: primaryLight, width: 2.0)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: errorLight)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: errorLight, width: 2.0)),
          labelStyle: GoogleFonts.inter(color: textMediumEmphasisLight, fontSize: 16, fontWeight: FontWeight.w400),
          hintStyle: GoogleFonts.inter(color: textDisabledLight, fontSize: 16, fontWeight: FontWeight.w400)),

      // Switch theme for restaurant settings
      switchTheme: SwitchThemeData(thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Colors.grey[300];
      }), trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight.withValues(alpha: 0.3);
        }
        return Colors.grey[200];
      })),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryLight;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
          side: BorderSide(color: outlineLight, width: 2.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))),

      // Radio theme
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return outlineLight;
      })),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primaryLight, linearTrackColor: primaryLight.withValues(alpha: 0.2), circularTrackColor: primaryLight.withValues(alpha: 0.2)),

      // Slider theme
      sliderTheme: SliderThemeData(activeTrackColor: primaryLight, thumbColor: primaryLight, overlayColor: primaryLight.withValues(alpha: 0.2), inactiveTrackColor: primaryLight.withValues(alpha: 0.3), trackHeight: 4.0),

      // Tab bar theme for menu categories
      tabBarTheme: TabBarTheme(labelColor: primaryLight, unselectedLabelColor: textMediumEmphasisLight, indicatorColor: primaryLight, indicatorSize: TabBarIndicatorSize.label, labelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600), unselectedLabelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400)),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(decoration: BoxDecoration(color: onSurfaceLight.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8.0)), textStyle: GoogleFonts.inter(color: surfaceLight, fontSize: 14, fontWeight: FontWeight.w400), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),

      // SnackBar theme for restaurant notifications
      snackBarTheme: SnackBarThemeData(backgroundColor: onSurfaceLight, contentTextStyle: GoogleFonts.inter(color: surfaceLight, fontSize: 16, fontWeight: FontWeight.w400), actionTextColor: primaryLight, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),

      // Chip theme for status indicators
      chipTheme: ChipThemeData(backgroundColor: outlineLight.withValues(alpha: 0.1), selectedColor: primaryLight.withValues(alpha: 0.2), labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),

      // List tile theme
      listTileTheme: ListTileThemeData(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), titleTextStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: onSurfaceLight), subtitleTextStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textMediumEmphasisLight)), dialogTheme: DialogThemeData(backgroundColor: dialogLight));

  /// Dark theme optimized for restaurant operations
  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: primaryDark,
          onPrimary: Colors.black,
          primaryContainer: primaryDark.withValues(alpha: 0.2),
          onPrimaryContainer: primaryDark,
          secondary: secondaryDark,
          onSecondary: Colors.black,
          secondaryContainer: secondaryDark.withValues(alpha: 0.2),
          onSecondaryContainer: secondaryDark,
          tertiary: successDark,
          onTertiary: Colors.black,
          tertiaryContainer: successDark.withValues(alpha: 0.2),
          onTertiaryContainer: successDark,
          error: errorDark,
          onError: Colors.black,
          surface: surfaceDark,
          onSurface: onSurfaceDark,
          onSurfaceVariant: onBackgroundDark,
          outline: outlineDark,
          outlineVariant: outlineDark.withValues(alpha: 0.5),
          shadow: shadowDark,
          scrim: Colors.black87,
          inverseSurface: surfaceLight,
          onInverseSurface: onSurfaceLight,
          inversePrimary: primaryLight),
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardDark,
      dividerColor: dividerDark,

      // AppBar theme for dark mode
      appBarTheme: AppBarTheme(
          backgroundColor: surfaceDark,
          foregroundColor: onSurfaceDark,
          elevation: 2.0,
          shadowColor: shadowDark,
          titleTextStyle: GoogleFonts.inter(
              fontSize: 20, fontWeight: FontWeight.w600, color: onSurfaceDark),
          iconTheme: IconThemeData(color: onSurfaceDark)),

      // Card theme for dark mode
      cardTheme: CardTheme(
          color: cardDark,
          elevation: 2.0,
          shadowColor: shadowDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          margin: const EdgeInsets.all(8.0)),

      // Bottom navigation for dark mode
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceDark,
          selectedItemColor: primaryDark,
          unselectedItemColor: textMediumEmphasisDark,
          elevation: 8.0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle:
              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle:
              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400)),

      // Floating action button for dark mode
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryDark,
          foregroundColor: Colors.black,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0))),

      // Button themes for dark mode
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: primaryDark,
              elevation: 2.0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              side: BorderSide(color: primaryDark, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),

      // Typography system for dark mode
      textTheme: _buildTextTheme(isLight: false),

      // Input decoration for dark mode
      inputDecorationTheme: InputDecorationTheme(
          fillColor: surfaceDark,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: outlineDark)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: outlineDark)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: primaryDark, width: 2.0)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: errorDark)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: errorDark, width: 2.0)),
          labelStyle: GoogleFonts.inter(color: textMediumEmphasisDark, fontSize: 16, fontWeight: FontWeight.w400),
          hintStyle: GoogleFonts.inter(color: textDisabledDark, fontSize: 16, fontWeight: FontWeight.w400)),

      // Switch theme for dark mode
      switchTheme: SwitchThemeData(thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return Colors.grey[600];
      }), trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark.withValues(alpha: 0.3);
        }
        return Colors.grey[700];
      })),

      // Checkbox theme for dark mode
      checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryDark;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.black),
          side: BorderSide(color: outlineDark, width: 2.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))),

      // Radio theme for dark mode
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return outlineDark;
      })),

      // Progress indicator theme for dark mode
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primaryDark, linearTrackColor: primaryDark.withValues(alpha: 0.2), circularTrackColor: primaryDark.withValues(alpha: 0.2)),

      // Slider theme for dark mode
      sliderTheme: SliderThemeData(activeTrackColor: primaryDark, thumbColor: primaryDark, overlayColor: primaryDark.withValues(alpha: 0.2), inactiveTrackColor: primaryDark.withValues(alpha: 0.3), trackHeight: 4.0),

      // Tab bar theme for dark mode
      tabBarTheme: TabBarTheme(labelColor: primaryDark, unselectedLabelColor: textMediumEmphasisDark, indicatorColor: primaryDark, indicatorSize: TabBarIndicatorSize.label, labelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600), unselectedLabelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400)),

      // Tooltip theme for dark mode
      tooltipTheme: TooltipThemeData(decoration: BoxDecoration(color: onSurfaceDark.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8.0)), textStyle: GoogleFonts.inter(color: surfaceDark, fontSize: 14, fontWeight: FontWeight.w400), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),

      // SnackBar theme for dark mode
      snackBarTheme: SnackBarThemeData(backgroundColor: onSurfaceDark, contentTextStyle: GoogleFonts.inter(color: surfaceDark, fontSize: 16, fontWeight: FontWeight.w400), actionTextColor: primaryDark, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),

      // Chip theme for dark mode
      chipTheme: ChipThemeData(backgroundColor: outlineDark.withValues(alpha: 0.2), selectedColor: primaryDark.withValues(alpha: 0.3), labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),

      // List tile theme for dark mode
      listTileTheme: ListTileThemeData(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), titleTextStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: onSurfaceDark), subtitleTextStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textMediumEmphasisDark)), dialogTheme: DialogThemeData(backgroundColor: dialogDark));

  /// Helper method to build text theme based on brightness using Inter font
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textHighEmphasis =
        isLight ? textHighEmphasisLight : textHighEmphasisDark;
    final Color textMediumEmphasis =
        isLight ? textMediumEmphasisLight : textMediumEmphasisDark;
    final Color textDisabled = isLight ? textDisabledLight : textDisabledDark;

    return TextTheme(
        // Display styles for large headings
        displayLarge: GoogleFonts.inter(
            fontSize: 57,
            fontWeight: FontWeight.w400,
            color: textHighEmphasis,
            letterSpacing: -0.25),
        displayMedium: GoogleFonts.inter(
            fontSize: 45, fontWeight: FontWeight.w400, color: textHighEmphasis),
        displaySmall: GoogleFonts.inter(
            fontSize: 36, fontWeight: FontWeight.w400, color: textHighEmphasis),

        // Headline styles for section headers
        headlineLarge: GoogleFonts.inter(
            fontSize: 32, fontWeight: FontWeight.w600, color: textHighEmphasis),
        headlineMedium: GoogleFonts.inter(
            fontSize: 28, fontWeight: FontWeight.w600, color: textHighEmphasis),
        headlineSmall: GoogleFonts.inter(
            fontSize: 24, fontWeight: FontWeight.w600, color: textHighEmphasis),

        // Title styles for cards and components
        titleLarge: GoogleFonts.inter(
            fontSize: 22, fontWeight: FontWeight.w500, color: textHighEmphasis),
        titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textHighEmphasis,
            letterSpacing: 0.15),
        titleSmall: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textHighEmphasis,
            letterSpacing: 0.1),

        // Body text styles for content
        bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textHighEmphasis,
            letterSpacing: 0.5),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textHighEmphasis,
            letterSpacing: 0.25),
        bodySmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textMediumEmphasis,
            letterSpacing: 0.4),

        // Label styles for buttons and small text
        labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textHighEmphasis,
            letterSpacing: 0.1),
        labelMedium: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textMediumEmphasis,
            letterSpacing: 0.5),
        labelSmall: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textDisabled,
            letterSpacing: 0.5));
  }
}
