import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';

/// Función helper para mostrar el bottom sheet de acciones de idioma
Future<String?> showLanguageActionBottomSheet(
  BuildContext context,
  bool isActive,
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
            // Opción dinámica según esté activo o no
            ListTile(
              leading: Icon(
                isActive
                    ? Icons.radio_button_unchecked
                    : Icons.check_circle_outline,
                color: isActive ? AppTheme.subtle : AppTheme.accent,
              ),
              title: Text(
                isActive ? 'Unset as active' : 'Set as active',
                style: TextStyle(color: AppTheme.text),
              ),
              onTap: () =>
                  Navigator.pop(ctx, isActive ? 'unactive' : 'active'),
            ),
            ListTile(
              leading: Icon(
                Icons.tune_rounded,
                color: AppTheme.subtle,
              ),
              title: Text(
                'Set level',
                style: TextStyle(color: AppTheme.text),
              ),
              onTap: () => Navigator.pop(ctx, 'level'),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: Text(
                'Remove language',
                style: TextStyle(color: AppTheme.text),
              ),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
            const SizedBox(height: AppDimensions.spacingSM),
          ],
        ),
      );
    },
  );
}

