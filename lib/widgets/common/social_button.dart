import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String icon;

  const SocialButton({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: _MonoLogo(text: icon),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        padding: AppDimensions.paddingButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        side: BorderSide(color: AppTheme.border),
      ),
    );
  }
}

class _MonoLogo extends StatelessWidget {
  final String text;

  const _MonoLogo({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.monoLogoSize,
      height: AppDimensions.monoLogoSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        color: AppTheme.card,
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.text),
      ),
    );
  }
}
