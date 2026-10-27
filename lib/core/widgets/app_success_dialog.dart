import 'dart:async';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppSuccessDialog extends StatefulWidget {
  final String message;
  final Duration autoDismissDuration;

  const AppSuccessDialog({
    super.key,
    required this.message,
    this.autoDismissDuration = const Duration(seconds: 2),
  });

  static Future<void> show(
    BuildContext context, {
    required String message,
    Duration autoDismissDuration = const Duration(seconds: 2),
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AppSuccessDialog(
        message: message,
        autoDismissDuration: autoDismissDuration,
      ),
    );
  }

  @override
  State<AppSuccessDialog> createState() => _AppSuccessDialogState();
}

class _AppSuccessDialogState extends State<AppSuccessDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoDismissDuration > Duration.zero) {
      _timer = Timer(widget.autoDismissDuration, () {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.of(context, rootNavigator: true).pop(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Image / GIF (132x132)
              Image.asset(
                'assets/icons/wallet/success_clock.gif',
                width: 132,
                height: 132,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              // Message
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'ExpoArabic',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: AppColors.onSurface(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
