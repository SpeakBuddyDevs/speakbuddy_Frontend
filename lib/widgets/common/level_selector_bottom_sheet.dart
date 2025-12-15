import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';

/// Función helper para mostrar el bottom sheet de selección de nivel
Future<String?> showLevelSelectorBottomSheet(
  BuildContext context,
  List<String> levels,
  String selectedLevel,
) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppTheme.card,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusL)),
    ),
    builder: (ctx) {
      return Padding(
        padding: AppDimensions.paddingBottomSheet,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final lvl in levels)
              ListTile(
                leading: Icon(
                  lvl == selectedLevel
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: lvl == selectedLevel
                      ? AppTheme.accent
                      : AppTheme.subtle,
                ),
                title: const Text(' '),
                subtitle: Text(
                  lvl,
                  style: TextStyle(color: AppTheme.text),
                ),
                onTap: () => Navigator.pop(ctx, lvl),
              ),
            const SizedBox(height: AppDimensions.spacingSM),
          ],
        ),
      );
    },
  );
}

