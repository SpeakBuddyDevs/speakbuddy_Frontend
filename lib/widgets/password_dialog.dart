import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/dimensions.dart';
import '../theme/app_theme.dart';

Future<void> showPasswordDialog(BuildContext context, {required String password}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PasswordDialog(password: password),
  );
}

class PasswordDialog extends StatelessWidget {
  final String password;

  const PasswordDialog({super.key, required this.password});

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: password));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña copiada al portapapeles'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      title: const Text(
        'Intercambio creado',
        style: TextStyle(color: AppTheme.text),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparte esta contraseña para que otros se unan:',
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeS,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingXL,
                vertical: AppDimensions.spacingL,
              ),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(color: AppTheme.accent, width: 2),
              ),
              child: SelectableText(
                password,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
        FilledButton.icon(
          onPressed: () => _copyToClipboard(context),
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: const Text('Copiar'),
        ),
      ],
    );
  }
}
