import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';

/// Scaffold reutilizable para bottom sheets con filtros u opciones.
///
/// Proporciona el layout estándar:
/// - Handle de arrastre.
/// - Header con título y botón de restablecer.
/// - Área de contenido con scroll.
/// - Botón de acción anclado en la parte inferior.
class AppBottomSheetScaffold extends StatelessWidget {
  final String title;
  final VoidCallback? onReset;
  final Widget content;
  final String actionLabel;
  final VoidCallback onAction;

  const AppBottomSheetScaffold({
    super.key,
    required this.title,
    this.onReset,
    required this.content,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.spacingMD),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: AppDimensions.fontSizeXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (onReset != null)
                  TextButton(
                    onPressed: onReset,
                    child: Text(
                      'Restablecer',
                      style: TextStyle(color: AppTheme.accent),
                    ),
                  ),
              ],
            ),
          ),
          Divider(color: AppTheme.border, height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              child: content,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spacingL,
              AppDimensions.spacingMD,
              AppDimensions.spacingL,
              AppDimensions.spacingL +
                  MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spacingL,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
