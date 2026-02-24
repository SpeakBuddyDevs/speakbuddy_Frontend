import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';

/// Botón de filtros para la pantalla Encontrar
class FiltersButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool hasActiveFilters;

  const FiltersButton({
    super.key,
    this.onPressed,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        Icons.filter_list_rounded,
        color: hasActiveFilters ? AppTheme.accent : AppTheme.subtle,
        size: AppDimensions.iconSizeM,
      ),
      label: Text(
        'Filters',
        style: TextStyle(
          color: hasActiveFilters ? AppTheme.accent : AppTheme.subtle,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingL,
          vertical: AppDimensions.spacingMD,
        ),
        side: BorderSide(
          color: hasActiveFilters ? AppTheme.accent : AppTheme.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
      ),
    );
  }
}

