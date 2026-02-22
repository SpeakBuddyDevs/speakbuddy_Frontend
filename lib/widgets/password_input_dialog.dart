import 'package:flutter/material.dart';
import '../constants/dimensions.dart';
import '../theme/app_theme.dart';

Future<String?> showPasswordInputDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const PasswordInputDialog(),
  );
}

class PasswordInputDialog extends StatefulWidget {
  const PasswordInputDialog({super.key});

  @override
  State<PasswordInputDialog> createState() => _PasswordInputDialogState();
}

class _PasswordInputDialogState extends State<PasswordInputDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final password = _controller.text.trim();
    if (password.isEmpty) {
      setState(() => _error = 'Introduce la contraseña');
      return;
    }
    Navigator.of(context).pop(password);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      title: Row(
        children: [
          Icon(Icons.lock_rounded, color: AppTheme.accent, size: 24),
          const SizedBox(width: AppDimensions.spacingSM),
          const Text(
            'Intercambio privado',
            style: TextStyle(color: AppTheme.text),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Introduce la contraseña para unirte:',
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeS,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 20,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                borderSide: BorderSide.none,
              ),
              hintText: 'XXXXXX',
              hintStyle: TextStyle(
                color: AppTheme.subtle.withOpacity(0.5),
                letterSpacing: 2,
              ),
              errorText: _error,
            ),
            onSubmitted: (_) => _onSubmit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _onSubmit,
          child: const Text('Unirse'),
        ),
      ],
    );
  }
}
