import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/english_digits_formatter.dart';
import '../../../../core/widgets/app_otp_input.dart';
import '../../../../core/widgets/app_success_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/phone_change/phone_change_cubit.dart';
import '../bloc/phone_change/phone_change_state.dart';

class ChangePhoneBottomSheet extends StatefulWidget {
  const ChangePhoneBottomSheet({super.key});

  @override
  State<ChangePhoneBottomSheet> createState() => _ChangePhoneBottomSheetState();
}

class _ChangePhoneBottomSheetState extends State<ChangePhoneBottomSheet> {
  final _currentPhoneController = TextEditingController();
  final _newPhoneController = TextEditingController();

  @override
  void dispose() {
    _currentPhoneController.dispose();
    _newPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<PhoneChangeCubit, PhoneChangeState>(
      listener: (context, state) {
        if (state is PhoneChangedSuccessfully) {
          Navigator.of(context).pop();
          AppSuccessDialog.show(
            context,
            message: l10n.phoneChangedTitle,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is PhoneChangeLoading;
        String? errorMessage;
        if (state is PhoneChangeError) {
          errorMessage = state.message;
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.changePhoneNumber,
                style: AppTextStyles.heading1(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (state is PhoneChangeInitial ||
                  state is PhoneChangeError &&
                      context.read<PhoneChangeCubit>().currentPhone == null ||
                  state is PhoneChangeLoading &&
                      context.read<PhoneChangeCubit>().currentPhone ==
                          null) ...[
                // Step 1: Current Phone
                Text(
                  l10n.enterCurrentPhone,
                  style: AppTextStyles.body(context),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _currentPhoneController,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: false,
                  ),
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  maxLength: 11,
                  inputFormatters: const [
                    EnglishDigitsOnlyFormatter(maxLength: 11),
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: l10n.currentPhoneLabel,
                    errorText: errorMessage == 'invalidPhone'
                        ? l10n.invalidPhone
                        : errorMessage,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<PhoneChangeCubit>().verifyCurrentPhone(
                            _currentPhoneController.text,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(l10n.verifyPhoneButton),
                ),
              ] else if (state is CurrentPhoneVerified ||
                  state is PhoneChangeError &&
                      context.read<PhoneChangeCubit>().newPhone == null ||
                  state is PhoneChangeLoading &&
                      context.read<PhoneChangeCubit>().newPhone == null) ...[
                // Step 2: New Phone
                Text(l10n.enterNewPhone, style: AppTextStyles.body(context)),
                const SizedBox(height: 12),
                TextField(
                  controller: _newPhoneController,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: false,
                  ),
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  maxLength: 11,
                  inputFormatters: const [
                    EnglishDigitsOnlyFormatter(maxLength: 11),
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: l10n.newPhoneLabel,
                    errorText: errorMessage == 'invalidPhone'
                        ? l10n.invalidPhone
                        : errorMessage,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<PhoneChangeCubit>().submitNewPhone(
                            _newPhoneController.text,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(l10n.verifyPhoneButton),
                ),
              ] else ...[
                // Step 3: OTP
                AppOtpInput(
                  isLoading: isLoading,
                  errorMessage: errorMessage,
                  onSubmit: (otp) {
                    context.read<PhoneChangeCubit>().verifyOtp(otp);
                  },
                  onResend: () {
                    context.read<PhoneChangeCubit>().submitNewPhone(
                      _newPhoneController.text,
                    );
                  },
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
