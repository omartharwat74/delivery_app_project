import 'dart:async';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../utils/english_digits_formatter.dart';

class AppOtpInput extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String> onSubmit;
  final VoidCallback onResend;

  const AppOtpInput({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.onSubmit,
    required this.onResend,
  });

  @override
  State<AppOtpInput> createState() => _AppOtpInputState();
}

class _AppOtpInputState extends State<AppOtpInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _timer;
  int _seconds = 59;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 59);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_seconds <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _seconds--);
    });
  }

  void _handleResend() {
    if (_seconds > 0) return;
    _controller.clear();
    _startTimer();
    widget.onResend();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    FocusManager.instance.primaryFocus?.unfocus();
    final otp = _controller.text.trim();
    if (otp.length < 6) return;
    widget.onSubmit(otp);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 6 OTP boxes - strictly LTR
        SizedBox(
          height: 48,
          child: Stack(
            children: [
              Positioned.fill(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: false,
                      decimal: false,
                    ),
                    maxLength: 6,
                    textAlign: TextAlign.left,
                    textDirection: TextDirection.ltr,
                    showCursor: false,
                    style: AppTextStyles.hiddenOtpInput,
                    inputFormatters: const [
                      EnglishDigitsOnlyFormatter(maxLength: 6),
                    ],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) => setState(() {}),
                    onSubmitted: (_) => _handleSubmit(),
                  ),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    final text = _controller.text;
                    final isFilled = index < text.length;
                    final char = isFilled ? text[index] : '-';

                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _focusNode.requestFocus,
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isFilled
                                ? AppColors.otpActiveBorder(context)
                                : AppColors.border(context),
                            width: isFilled ? 1.0 : 0.5,
                          ),
                        ),
                        child: Text(
                          char,
                          style: isFilled
                              ? AppTextStyles.otpDigitActive(context).copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                )
                              : AppTextStyles.otpDigitInactive(context),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        if (widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              widget.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),

        const SizedBox(height: 24),

        // Verify button
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: (_controller.text.length == 6 && !widget.isLoading)
                ? _handleSubmit
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    l10n.otpVerify,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 24),

        // Countdown timer & Resend button row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.otpTimerSeconds(_seconds),
              style: AppTextStyles.timerText(context),
            ),
            const SizedBox(width: 6),
            TextButton(
              onPressed: _seconds == 0 ? _handleResend : null,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.otpResend,
                style: AppTextStyles.textLink(context).copyWith(
                  color: _seconds == 0
                      ? AppColors.primary
                      : AppColors.paragraph(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
