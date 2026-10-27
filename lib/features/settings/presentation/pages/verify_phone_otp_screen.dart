import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../core/widgets/app_directional_icons.dart';
import '../../../../core/widgets/app_success_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
import 'verify_phone_otp_args.dart';

class VerifyPhoneOtpScreen extends StatefulWidget {
  const VerifyPhoneOtpScreen({super.key, required this.args});

  final VerifyPhoneOtpArgs args;

  @override
  State<VerifyPhoneOtpScreen> createState() => _VerifyPhoneOtpScreenState();
}

class _VerifyPhoneOtpScreenState extends State<VerifyPhoneOtpScreen> {
  static const _resendStartSeconds = 59;

  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();

  Timer? _resendTimer;
  int _secondsRemaining = _resendStartSeconds;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _otpFocusNode.addListener(_onFocusChanged);
    _startResendCountdown();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _otpFocusNode.requestFocus();
      // If entering for the current phone and OTP was not triggered yet, trigger it
      if (widget.args.isCurrentPhone) {
        final state = context.read<SettingsCubit>().state;
        if (!state.sendCurrentOtpSuccess && !state.isLoading) {
          context.read<SettingsCubit>().sendCurrentOtp();
        }
      }
    });
  }

  @override
  void dispose() {
    _otpFocusNode.removeListener(_onFocusChanged);
    _resendTimer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {});
  }

  int get _activeBoxIndex {
    if (!_otpFocusNode.hasFocus && _otpController.text.isEmpty) return -1;
    final length = _otpController.text.length;
    if (length == 0) return 0;
    if (length >= 6) return 5;
    return length - 1;
  }

  String _charAt(int index) {
    final text = _otpController.text;
    if (index >= text.length) return '-';
    return text[index];
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        timer.cancel();
        _resendTimer = null;
        setState(() => _secondsRemaining = 0);
        return;
      }

      setState(() => _secondsRemaining--);
    });
  }

  void _restartResendCountdown() {
    _resendTimer?.cancel();
    if (!mounted) return;
    setState(() => _secondsRemaining = _resendStartSeconds);
    _startResendCountdown();
  }

  void _onResendCode() {
    if (_secondsRemaining > 0 || _isCompleting) return;

    if (widget.args.isCurrentPhone) {
      context.read<SettingsCubit>().sendCurrentOtp();
    } else {
      final phone = widget.args.newPhoneNumber ?? widget.args.phoneNumber;
      context.read<SettingsCubit>().sendNewPhoneOtp(phone.formatAsEgyptianPhone());
    }

    _otpController.clear();
    setState(() {});
    _otpFocusNode.requestFocus();
    _restartResendCountdown();
  }

  void _onOtpChanged(String value) {
    if (_isCompleting) return;
    setState(() {});
    if (value.length < 6) return;

    FocusManager.instance.primaryFocus?.unfocus();

    if (widget.args.isCurrentPhone) {
      context.read<SettingsCubit>().verifyCurrentOtp(value);
    } else {
      context.read<SettingsCubit>().verifyNewPhoneOtp(value);
    }
  }

  Future<void> _showSuccessDialogAndReturn() async {
    if (_isCompleting) return;
    _resendTimer?.cancel();
    setState(() => _isCompleting = true);

    final l10n = AppLocalizations.of(context);
    await AppSuccessDialog.show(
      context,
      message: l10n?.phoneChangedTitle ?? 'تم تغيير رقم الجوال بنجاح',
    );

    if (!mounted) return;
    context.read<SettingsCubit>().resetPhoneChangeFlow();
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(RouteNames.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.scaffoldBackground(context),
      body: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (prev, curr) =>
            (curr.verifyCurrentOtpSuccess != prev.verifyCurrentOtpSuccess &&
                curr.verifyCurrentOtpSuccess) ||
            (curr.changePhoneSuccess != prev.changePhoneSuccess &&
                curr.changePhoneSuccess) ||
            (curr.errorMessage != prev.errorMessage &&
                curr.errorMessage != null),
        listener: (context, state) {
          if (state.errorMessage != null) {
            setState(() => _isCompleting = false);
            _otpController.clear();
            _otpFocusNode.requestFocus();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
                  style: AppTextStyles.snackBarMessage(context),
                ),
                backgroundColor: AppColors.error,
              ),
            );
            context.read<SettingsCubit>().resetActionStatus();
          } else if (widget.args.isCurrentPhone &&
              state.verifyCurrentOtpSuccess) {
            context.pushReplacementNamed(RouteNames.changePhone);
          } else if (!widget.args.isCurrentPhone && state.changePhoneSuccess) {
            _showSuccessDialogAndReturn();
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _OtpBackHeader(isCurrentPhone: widget.args.isCurrentPhone),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsetsDirectional.fromSTEB(
                          16,
                          0,
                          16,
                          MediaQuery.viewInsetsOf(context).bottom + 24,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _OtpIntro(
                                title: l10n.verifyPhoneTitle,
                                subtitle: l10n.verifyPhoneMessage,
                              ),
                              const SizedBox(height: 24),
                              _OtpInput(
                                controller: _otpController,
                                focusNode: _otpFocusNode,
                                activeBoxIndex: _activeBoxIndex,
                                charAt: _charAt,
                                onChanged: _onOtpChanged,
                              ),
                              const SizedBox(height: 24),
                              _ResendCodeRow(
                                resendLabel: l10n.resendCode,
                                timerLabel: _secondsRemaining > 0
                                    ? l10n.resendCodeTimer(_secondsRemaining)
                                    : null,
                                enabled:
                                    _secondsRemaining == 0 && !_isCompleting,
                                onTap: _onResendCode,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpBackHeader extends StatelessWidget {
  const _OtpBackHeader({this.isCurrentPhone = true});

  final bool isCurrentPhone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 20),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (isCurrentPhone) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(RouteNames.settings);
              }
            } else {
              context.pushReplacementNamed(RouteNames.changePhone);
            }
          },
          child: SizedBox(
            width: 28,
            height: 28,
            child: Icon(
              AppDirectionalIcons.backChevron(context),
              size: 28,
              color: AppColors.onSurface(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpIntro extends StatelessWidget {
  const _OtpIntro({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(AppAssets.profilePhoneOtpIcon, width: 49, height: 49),
        const SizedBox(height: 16),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.heading4(context).copyWith(
            color: AppColors.onSurface(context),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.footerSecondary(context).copyWith(
            color: AppColors.paragraph(context),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _OtpInput extends StatelessWidget {
  const _OtpInput({
    required this.controller,
    required this.focusNode,
    required this.activeBoxIndex,
    required this.charAt,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int activeBoxIndex;
  final String Function(int index) charAt;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxSize = ((constraints.maxWidth - 40) / 6).clamp(40.0, 48.0);

          return Stack(
            children: [
              Positioned.fill(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.left,
                    textDirection: TextDirection.ltr,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    style: AppTextStyles.hiddenOtpInput,
                    showCursor: false,
                    cursorColor: AppColors.transparent,
                    cursorWidth: 0,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      counterText: '',
                    ),
                    onChanged: onChanged,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  ),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var index = 0; index < 6; index++)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => focusNode.requestFocus(),
                        child: _OtpDigitBox(
                          char: charAt(index),
                          active: index == activeBoxIndex,
                          size: boxSize,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OtpDigitBox extends StatelessWidget {
  const _OtpDigitBox({
    required this.char,
    required this.active,
    required this.size,
  });

  final String char;
  final bool active;
  final double size;

  bool get _isPlaceholder => char == '-';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? AppColors.otpActiveBorder(context)
              : AppColors.border(context),
          width: 0.5,
        ),
      ),
      child: Text(
        char,
        textAlign: TextAlign.center,
        style: AppTextStyles.otpDigitActive(context).copyWith(
          color: _isPlaceholder
              ? AppColors.paragraph(context)
              : AppColors.onSurface(context),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.3,
        ),
      ),
    );
  }
}

class _ResendCodeRow extends StatelessWidget {
  const _ResendCodeRow({
    required this.resendLabel,
    required this.enabled,
    required this.onTap,
    this.timerLabel,
  });

  final String resendLabel;
  final String? timerLabel;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? onTap : null,
              child: Text(
                resendLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: Directionality.of(context),
                style: AppTextStyles.footerSecondary(context).copyWith(
                  color: enabled ? AppColors.primary : Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ),
          ),
          if (timerLabel != null) ...[
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                timerLabel!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: Directionality.of(context),
                style: AppTextStyles.footerSecondary(context).copyWith(
                  color: AppColors.paragraph(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
