import 'package:flutter/material.dart';
import '../../constants/languages.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';

/// Función helper para mostrar el bottom sheet de selección de idioma
Future<String?> showLanguageSelectorBottomSheet(
  BuildContext context,
  List<String> availableCodes,
  String initialValue,
) {
  String selected = initialValue;
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppTheme.card,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusL)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: AppDimensions.paddingCard,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selected,
                  isExpanded: true,
                  dropdownColor: AppTheme.card,
                  style: TextStyle(color: AppTheme.text),
                  decoration: const InputDecoration(
                    labelText: 'Selecciona un idioma',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  items: availableCodes
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            AppLanguages.getName(c),
                            style: TextStyle(color: AppTheme.text),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => selected = v);
                    }
                  },
                ),
                const SizedBox(height: AppDimensions.spacingMD),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, selected),
                    child: const Text('Añadir'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

