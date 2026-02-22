import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../constants/dimensions.dart';

class StarRatingPicker extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onRatingChanged;
  final double starSize;
  final bool enabled;

  const StarRatingPicker({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.starSize = 40.0,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isFilled = starNumber <= rating;

        return GestureDetector(
          onTap: enabled && onRatingChanged != null
              ? () => onRatingChanged!(starNumber)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingXS,
            ),
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: starSize,
              color: isFilled
                  ? AppTheme.gold
                  : (enabled ? AppTheme.subtle : AppTheme.border),
            ),
          ),
        );
      }),
    );
  }
}

class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final double starSize;
  final bool showValue;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.starSize = 16.0,
    this.showValue = true,
  });

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          IconData icon;
          if (index < fullStars) {
            icon = Icons.star_rounded;
          } else if (index == fullStars && hasHalfStar) {
            icon = Icons.star_half_rounded;
          } else {
            icon = Icons.star_outline_rounded;
          }

          return Icon(
            icon,
            size: starSize,
            color: index < fullStars || (index == fullStars && hasHalfStar)
                ? AppTheme.gold
                : AppTheme.subtle,
          );
        }),
        if (showValue) ...[
          const SizedBox(width: AppDimensions.spacingSM),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: AppTheme.text,
              fontSize: starSize * 0.9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
