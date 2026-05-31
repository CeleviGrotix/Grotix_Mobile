// lib/common/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grotix/common/theme/app_colors.dart';

ThemeData getAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.black,
    primaryColor: AppColors.greenEmerald,

    // Estilo global por defecto usando GoogleFonts.gabaritoTextTheme
    fontFamily: GoogleFonts.gabarito().fontFamily,

    // Text Theme mapeando pesos visuales (Regular, Semibold, Bold, ExtraBold)
    textTheme: TextTheme(
      // Títulos Grandes (Ej: "AI Image Processing", "Cultivation Areas")
      headlineLarge: GoogleFonts.gabarito(
        fontWeight: FontWeight.w800, // ExtraBold
        fontSize: 32,
        color: AppColors.white,
      ),
      // Títulos de Sección (Ej: "ZONE STATUS", "PERSONAL INFO")
      headlineMedium: GoogleFonts.gabarito(
        fontWeight: FontWeight.w700, // Bold
        fontSize: 22,
        color: AppColors.redCoral,
      ),
      // Títulos de Tarjetas / Nombres (Ej: "Zona Tomatitos", "Tomio Nakamurakare")
      titleLarge: GoogleFonts.gabarito(
        fontWeight: FontWeight.w600, // SemiBold
        fontSize: 18,
        color: AppColors.white,
      ),
      // Cuerpo de texto general fuerte (Indicadores óptimos, variables)
      bodyLarge: GoogleFonts.gabarito(
        fontWeight: FontWeight.w500, // Medium
        fontSize: 16,
        color: AppColors.white,
      ),
      // Descripciones chicas (Ej: "Last update 10:58", "Stage: SEED")
      bodyMedium: GoogleFonts.gabarito(
        fontWeight: FontWeight.w400, // Regular
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    ),

    // Ajuste específico para que coincida con el MainShell oscuro
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: AppColors.darkNavBarG,
      elevation: 0,
    ),
  );
}