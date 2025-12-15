import 'package:flutter/material.dart';

/// Constantes de dimensiones, espaciados y tamaños de la aplicación
///
/// Este archivo centraliza todos los valores numéricos hardcodeados
/// para mejorar la mantenibilidad y consistencia visual.
class AppDimensions {
  // ==================== ESPACIADO (SPACING) ====================
  /// Espaciado extra pequeño
  static const double spacingXS = 4.0;

  /// Espaciado pequeño
  static const double spacingS = 6.0;

  /// Espaciado pequeño-mediano
  static const double spacingSM = 8.0;

  /// Espaciado mediano
  static const double spacingM = 10.0;

  /// Espaciado mediano
  static const double spacingMD = 12.0;

  /// Espaciado mediano-grande
  static const double spacingML = 14.0;

  /// Espaciado grande
  static const double spacingL = 16.0;

  /// Espaciado extra grande
  static const double spacingXL = 18.0;

  /// Espaciado muy grande
  static const double spacingXXL = 22.0;

  /// Espaciado extra muy grande
  static const double spacingXXXL = 24.0;

  // ==================== PADDING ====================
  /// Padding de pantalla
  static const EdgeInsets paddingScreen = EdgeInsets.fromLTRB(16, 8, 16, 24);

  /// Padding de tarjeta
  static const EdgeInsets paddingCard = EdgeInsets.all(16);

  /// Padding de tarjeta pequeña
  static const EdgeInsets paddingCardSmall = EdgeInsets.all(12);

  /// Padding de formulario
  static const EdgeInsets paddingForm = EdgeInsets.symmetric(horizontal: 22, vertical: 26);

  /// Padding de input
  static const EdgeInsets paddingInput = EdgeInsets.symmetric(horizontal: 14, vertical: 16);

  /// Padding vertical de input
  static const EdgeInsets paddingInputVertical = EdgeInsets.symmetric(vertical: 20);

  /// Padding de bottom sheet
  static const EdgeInsets paddingBottomSheet = EdgeInsets.fromLTRB(16, 8, 16, 16);

  /// Padding de botón
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(vertical: 12);

  /// Padding de botón grande
  static const EdgeInsets paddingButtonLarge = EdgeInsets.symmetric(vertical: 16);

  /// Padding de divisor
  static const EdgeInsets paddingDivider = EdgeInsets.symmetric(horizontal: 10);

  // ==================== BORDER RADIUS ====================
  /// Radio extra pequeño
  static const double radiusXS = 4.0;

  /// Radio pequeño
  static const double radiusS = 8.0;

  /// Radio mediano
  static const double radiusM = 10.0;

  /// Radio mediano
  static const double radiusMD = 12.0;

  /// Radio mediano-grande
  static const double radiusML = 14.0;

  /// Radio grande
  static const double radiusL = 16.0;

  /// Radio extra grande
  static const double radiusXL = 18.0;

  /// Radio circular completo
  static const double radiusCircular = 999.0;

  // ==================== TAMAÑOS DE FUENTE ====================
  /// Fuente extra pequeña
  static const double fontSizeXS = 12.0;

  /// Fuente pequeña
  static const double fontSizeS = 13.0;

  /// Fuente mediana
  static const double fontSizeM = 16.0;

  /// Fuente grande
  static const double fontSizeL = 18.0;

  /// Fuente extra grande
  static const double fontSizeXL = 20.0;

  // ==================== TAMAÑOS DE ICONOS ====================
  /// Icono pequeño
  static const double iconSizeS = 16.0;

  /// Icono mediano
  static const double iconSizeM = 22.0;

  /// Icono grande
  static const double iconSizeL = 30.0;

  /// Icono extra grande
  static const double iconSizeXL = 36.0;

  // ==================== TAMAÑOS DE WIDGETS ====================
  /// Tamaño del logo
  static const double logoSize = 62.0;

  /// Avatar pequeño
  static const double avatarSizeS = 30.0;

  /// Avatar mediano
  static const double avatarSizeM = 36.0;

  /// Tamaño de badge
  static const double badgeSize = 38.0;

  /// Altura de botón
  static const double buttonHeight = 44.0;

  /// Ancho de barra de progreso
  static const double progressBarWidth = 80.0;

  /// Altura de barra de progreso
  static const double progressBarHeight = 6.0;

  /// Tamaño de logo mono
  static const double monoLogoSize = 22.0;

  // ==================== BREAKPOINTS Y CONSTRAINTS ====================
  /// Ancho máximo de tarjeta
  static const double maxCardWidth = 420.0;

  /// Breakpoint para pantallas grandes
  static const double breakpointLarge = 600.0;

  // ==================== OTROS VALORES ====================
  /// Altura de línea
  static const double lineHeight = 1.4;

  /// Calidad de imagen
  static const int imageQuality = 85;

  /// Opacidad deshabilitado
  static const double opacityDisabled = 0.5;

  /// Opacidad divisor
  static const double opacityDivider = 0.3;
}

