import 'package:flutter/material.dart';
import '../constants/dimensions.dart';
import '../theme/app_theme.dart';
import '../models/review.dart';
import '../repositories/api_reviews_repository.dart';
import 'star_rating_picker.dart';

Future<bool?> showRateUserDialog(
  BuildContext context, {
  required String userId,
  required String userName,
  String? avatarUrl,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => RateUserDialog(
      userId: userId,
      userName: userName,
      avatarUrl: avatarUrl,
    ),
  );
}

class RateUserDialog extends StatefulWidget {
  final String userId;
  final String userName;
  final String? avatarUrl;

  const RateUserDialog({
    super.key,
    required this.userId,
    required this.userName,
    this.avatarUrl,
  });

  @override
  State<RateUserDialog> createState() => _RateUserDialogState();
}

class _RateUserDialogState extends State<RateUserDialog> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  final _reviewsRepository = ApiReviewsRepository();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      setState(() => _error = 'Selecciona al menos 1 estrella');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final review = ReviewRequest(
      score: _rating,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    final success = await _reviewsRepository.submitReview(widget.userId, review);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSubmitting = false;
        _error = 'Error al enviar la valoración. Inténtalo de nuevo.';
      });
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
        'Valorar usuario',
        style: TextStyle(color: AppTheme.text),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppTheme.border,
              backgroundImage: widget.avatarUrl != null
                  ? NetworkImage(widget.avatarUrl!)
                  : null,
              child: widget.avatarUrl == null
                  ? Text(
                      widget.userName.isNotEmpty
                          ? widget.userName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: AppDimensions.spacingMD),
            Text(
              widget.userName,
              style: const TextStyle(
                color: AppTheme.text,
                fontSize: AppDimensions.fontSizeL,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXXL),
            const Text(
              '¿Cómo fue tu experiencia?',
              style: TextStyle(
                color: AppTheme.subtle,
                fontSize: AppDimensions.fontSizeS,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            StarRatingPicker(
              rating: _rating,
              onRatingChanged: (value) => setState(() {
                _rating = value;
                _error = null;
              }),
              starSize: 44,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: AppDimensions.spacingXXL),
            TextField(
              controller: _commentController,
              enabled: !_isSubmitting,
              maxLines: 3,
              maxLength: 500,
              style: const TextStyle(color: AppTheme.text),
              decoration: InputDecoration(
                hintText: 'Comentario opcional...',
                hintStyle: const TextStyle(color: AppTheme.subtle),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  borderSide: BorderSide.none,
                ),
                counterStyle: const TextStyle(color: AppTheme.subtle),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppDimensions.spacingSM),
              Text(
                _error!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: AppDimensions.fontSizeXS,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Omitir'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Enviar'),
        ),
      ],
    );
  }
}
