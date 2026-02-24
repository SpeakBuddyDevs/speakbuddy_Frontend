import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';

/// Título de sección dentro de un formulario de filtros.
class FilterSectionTitle extends StatelessWidget {
  final String title;

  const FilterSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSM),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.subtle,
          fontSize: AppDimensions.fontSizeS,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Dropdown estilizado para filtros.
class FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingL,
        vertical: AppDimensions.spacingXS,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: TextStyle(color: AppTheme.subtle),
          ),
          isExpanded: true,
          dropdownColor: AppTheme.card,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.subtle,
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Todos',
                style: TextStyle(color: AppTheme.subtle),
              ),
            ),
            ...items.map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(color: AppTheme.text),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Switch estilizado para filtros.
class FilterSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const FilterSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppTheme.border),
      ),
      child: SwitchListTile(
        title: Text(
          label,
          style: TextStyle(color: AppTheme.text),
        ),
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppTheme.accent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingL,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
      ),
    );
  }
}
