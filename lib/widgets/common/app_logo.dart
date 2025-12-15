import 'package:flutter/material.dart';
import '../../constants/dimensions.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  static const Color gradientStart = Color(0xFF4A90E2);
  static const Color gradientEnd = Color(0xFF8A49F7);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.logoSize,
      height: AppDimensions.logoSize,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
      ),
      child: Center(
        child: Icon(Icons.chat_bubble_outline, color: Colors.white, size: AppDimensions.iconSizeL),
      ),
    );
  }
}

