import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_otp_input.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class OtpPage extends StatefulWidget {
  final String? phoneNumber;
  const OtpPage({super.key, this.phoneNumber});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
      context.read<AuthCubit>().setPhoneNumber(widget.phoneNumber!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground(context),
        body: SafeArea(
          child: BlocListener<AuthCubit, AuthState>(
            listenWhen: (prev, curr) =>
                curr is AuthAuthenticated ||
                curr is AuthCompleteRegistration ||
                curr is AuthOtpVerified ||
                curr is AuthError ||
                curr is AuthPhoneSubmitted,
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                context.go('/home');
              } else if (state is AuthCompleteRegistration) {
                context.go('/register', extra: state.phone);
              } else if (state is AuthOtpVerified) {
                if (state.isNewDriver) {
                  final phone = widget.phoneNumber ??
                      context.read<AuthCubit>().phoneNumber;
                  context.go('/register', extra: phone);
                } else {
                  context.go('/home');
                }
              } else if (state is AuthPhoneSubmitted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.otpResentSnackbar,
                      style: AppTextStyles.snackBarMessage(context),
                    ),
                  ),
                );
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: AppTextStyles.snackBarMessage(context),
                    ),
                  ),
                );
              }
            },
            child: SizedBox.expand(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/login');
                          }
                        },
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: AppColors.onSurface(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.otpTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.screenTitle(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.otpSubtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subtitle(context),
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<AuthCubit, AuthState>(
                      buildWhen: (prev, curr) =>
                          curr is AuthLoading ||
                          curr is AuthInitial ||
                          curr is AuthError ||
                          curr is AuthOtpVerified ||
                          curr is AuthPhoneSubmitted,
                      builder: (context, state) {
                        String? errorMessage;
                        if (state is AuthError) {
                          errorMessage = state.message;
                        }

                        return AppOtpInput(
                          isLoading: state is AuthLoading,
                          errorMessage: errorMessage,
                          onSubmit: (otp) {
                            context.read<AuthCubit>().verifyOtp(otp);
                          },
                          onResend: () {
                            final phone = widget.phoneNumber ??
                                context.read<AuthCubit>().phoneNumber;
                            context.read<AuthCubit>().resendOtp(phone: phone);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
