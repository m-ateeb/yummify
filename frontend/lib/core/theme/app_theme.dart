import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF00BFA5);
  static const Color secondaryColor = Color(0xFF7C4DFF);
  static const Color accentColor = Color(0xFFFF5252);
  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimaryColor = Color(0xFF2D3142);
  static const Color textSecondaryColor = Color(0xFF9E9E9E);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFFB300);

  // Gradient colors
  static const List<Color> primaryGradient = [Color(0xFF00BFA5), Color(0xFF1DE9B6)];
  static const List<Color> secondaryGradient = [Color(0xFF7C4DFF), Color(0xFFB388FF)];
  static const List<Color> accentGradient = [Color(0xFFFF5252), Color(0xFFFF8A80)];

  static ThemeData lightTheme() {
    final ThemeData base = ThemeData.light();

    return base.copyWith(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cardColor,
        shadowColor: Colors.black.withOpacity(0.1),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryColor,
        iconTheme: IconThemeData(color: textPrimaryColor),
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        elevation: 8,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
      ),
      textTheme: _buildTextTheme(base.textTheme),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(color: textSecondaryColor),
        hintStyle: const TextStyle(color: textSecondaryColor, fontSize: 14),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor;
            }
            return Colors.transparent;
          },
        ),
        side: const BorderSide(width: 1.5, color: Color(0xFFE0E0E0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor;
            }
            return Colors.grey.shade400;
          },
        ),
        trackColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor.withOpacity(0.5);
            }
            return Colors.grey.shade300;
          },
        ),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: textSecondaryColor,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        space: 1,
        thickness: 1,
        color: Color(0xFFEEEEEE),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.outfitTextTheme(
      base.copyWith(
        displayLarge: base.displayLarge!.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 28.0,
          letterSpacing: -0.5,
          color: textPrimaryColor,
        ),
        displayMedium: base.displayMedium!.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 24.0,
          letterSpacing: -0.5,
          color: textPrimaryColor,
        ),
        displaySmall: base.displaySmall!.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 20.0,
          letterSpacing: -0.5,
          color: textPrimaryColor,
        ),
        headlineMedium: base.headlineMedium!.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 18.0,
          letterSpacing: -0.5,
          color: textPrimaryColor,
        ),
        headlineSmall: base.headlineSmall!.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16.0,
          color: textPrimaryColor,
        ),
        titleLarge: base.titleLarge!.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16.0,
          color: textPrimaryColor,
        ),
        titleMedium: base.titleMedium!.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 15.0,
          color: textPrimaryColor,
        ),
        titleSmall: base.titleSmall!.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 14.0,
          color: textPrimaryColor,
        ),
        bodyLarge: base.bodyLarge!.copyWith(
          fontWeight: FontWeight.normal,
          fontSize: 15.0,
          color: textPrimaryColor,
        ),
        bodyMedium: base.bodyMedium!.copyWith(
          fontWeight: FontWeight.normal,
          fontSize: 14.0,
          color: textPrimaryColor,
        ),
        bodySmall: base.bodySmall!.copyWith(
          fontWeight: FontWeight.normal,
          fontSize: 12.0,
          color: textSecondaryColor,
        ),
        labelLarge: base.labelLarge!.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 14.0,
          color: primaryColor,
        ),
        labelSmall: base.labelSmall!.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 11.0,
          color: textSecondaryColor,
        ),
      ),
    );
  }

  // Helper methods for gradients
  static LinearGradient getPrimaryGradient() {
    return const LinearGradient(
      colors: primaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getSecondaryGradient() {
    return const LinearGradient(
      colors: secondaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getAccentGradient() {
    return const LinearGradient(
      colors: accentGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
