import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Reusable full-screen error / blocked state view.
/// Pixel-matched to the Wallet error state design:
/// - Icons.error_outline (size 48, AppColors.error)
/// - Text with ExpoArabic font, 14pt, w400, onSurface color
/// - Primary ElevatedButton with 10px rounded corners and retry label
class ErrorStateView extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  final String? retryLabel;

  const ErrorStateView({
    super.key,
    this.message,
    required this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Clean message string if it contains raw exception prefixes
    String displayMessage = (message ?? '').trim();
    if (displayMessage.startsWith('ForbiddenException:')) {
      displayMessage =
          displayMessage.replaceFirst('ForbiddenException:', '').trim();
    } else if (displayMessage.startsWith('Exception:')) {
      displayMessage = displayMessage.replaceFirst('Exception:', '').trim();
    }

    bool isDriverBlocked = displayMessage.contains('محظور') ||
        displayMessage.toLowerCase().contains('blocked');
    try {
      final authDriver =
          BlocProvider.of<AuthCubit>(context, listen: false).currentDriver;
      if (authDriver?.status.toLowerCase() == 'blocked') {
        isDriverBlocked = true;
      }
    } catch (_) {}

    if (isDriverBlocked) {
      displayMessage =
          l10n?.accountBlockedMessage ?? 'حسابك محظور. تواصل مع الدعم';
    } else if (displayMessage.isEmpty) {
      displayMessage = 'حدث خطأ أثناء تحميل البيانات';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'ExpoArabic',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurface(context),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                retryLabel ?? (l10n?.retry ?? 'إعادة المحاولة'),
                style: const TextStyle(
                  fontFamily: 'ExpoArabic',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
