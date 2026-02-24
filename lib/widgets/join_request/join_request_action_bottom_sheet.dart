import 'package:flutter/material.dart';

import '../../constants/dimensions.dart';
import '../../models/join_request.dart';
import '../../repositories/api_public_exchanges_repository.dart';
import '../../theme/app_theme.dart';
import '../../utils/requirement_display.dart';

/// Bottom sheet para que el creador acepte o rechace una solicitud de unión.
/// Se muestra al pulsar una notificación EXCHANGE_JOIN_REQUEST.
Future<bool?> showJoinRequestActionBottomSheet(
  BuildContext context, {
  required String exchangeId,
  required int requesterUserId,
  String exchangeTitle = 'Exchange',
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _JoinRequestActionBottomSheet(
      exchangeId: exchangeId,
      requesterUserId: requesterUserId,
      exchangeTitle: exchangeTitle,
    ),
  );
}

class _JoinRequestActionBottomSheet extends StatefulWidget {
  final String exchangeId;
  final int requesterUserId;
  final String exchangeTitle;

  const _JoinRequestActionBottomSheet({
    required this.exchangeId,
    required this.requesterUserId,
    required this.exchangeTitle,
  });

  @override
  State<_JoinRequestActionBottomSheet> createState() =>
      _JoinRequestActionBottomSheetState();
}

class _JoinRequestActionBottomSheetState
    extends State<_JoinRequestActionBottomSheet> {
  final _exchangeRepo = ApiPublicExchangesRepository();

  JoinRequest? _request;
  bool _isLoading = true;
  String? _error;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  Future<void> _loadRequest() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final requests = await _exchangeRepo.getJoinRequests(widget.exchangeId);
      if (!mounted) return;
      JoinRequest? match;
      for (final r in requests) {
        if (r.userId == widget.requesterUserId) {
          match = r;
          break;
        }
      }
      setState(() {
        _request = match;
        _isLoading = false;
        if (match == null && requests.isNotEmpty) {
          _error = 'Request not found or already responded to';
        } else if (match == null) {
          _error = 'No pending requests';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _accept() async {
    final request = _request;
    if (request == null || _isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      await _exchangeRepo.acceptJoinRequest(
        widget.exchangeId,
        request.id.toString(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request accepted')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  Future<void> _reject() async {
    final request = _request;
    if (request == null || _isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      await _exchangeRepo.rejectJoinRequest(
        widget.exchangeId,
        request.id.toString(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request rejected')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppDimensions.spacingL,
        right: AppDimensions.spacingL,
        top: AppDimensions.spacingL,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.spacingL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingL),
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Join request',
            style: TextStyle(
              color: AppTheme.text,
              fontSize: AppDimensions.fontSizeL,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimensions.spacingXL),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingL),
              child: Column(
                children: [
                  Text(
                    _error!,
                    style: TextStyle(color: AppTheme.subtle),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            )
          else if (_request != null)
            _buildRequestContent(),
        ],
      ),
    );
  }

  Widget _buildRequestContent() {
    final request = _request!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_rounded, color: AppTheme.accent, size: 20),
            const SizedBox(width: AppDimensions.spacingSM),
            Expanded(
              child: Text(
                request.username,
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: AppDimensions.fontSizeM,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingSM),
        Row(
          children: [
            Icon(Icons.event_rounded, color: AppTheme.subtle, size: 18),
            const SizedBox(width: AppDimensions.spacingSM),
            Expanded(
              child: Text(
                widget.exchangeTitle,
                style: TextStyle(
                  color: AppTheme.subtle,
                  fontSize: AppDimensions.fontSizeS,
                ),
              ),
            ),
          ],
        ),
        if (request.unmetRequirements != null &&
            request.unmetRequirements!.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacingMD),
          Text(
            'Requirements not met:',
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeXS,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          ...request.unmetRequirements!.map(
            (r) => Padding(
              padding: const EdgeInsets.only(left: AppDimensions.spacingMD),
              child: Text(
                '• ${translateRequirement(r)}',
                style: TextStyle(
                  color: AppTheme.subtle,
                  fontSize: AppDimensions.fontSizeXS,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.spacingXL),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isProcessing ? null : _reject,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                ),
                child: const Text('Reject'),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMD),
            Expanded(
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _accept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Accept'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
