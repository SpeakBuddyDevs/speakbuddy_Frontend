import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';

/// Barra de búsqueda para la pantalla Encontrar
class FindSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const FindSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText = 'Search for partners...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppTheme.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: AppTheme.text),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppTheme.subtle),
          prefixIcon: Icon(Icons.search_rounded, color: AppTheme.subtle),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingL,
            vertical: AppDimensions.spacingML,
          ),
        ),
      ),
    );
  }
}

