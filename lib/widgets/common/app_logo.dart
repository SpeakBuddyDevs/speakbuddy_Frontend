import 'package:flutter/material.dart';
import '../../constants/dimensions.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDimensions.logoSize,
      height: AppDimensions.logoSize,
      child: Image.asset(
        'lib/assets/images/logoSpeakBuddy.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

