import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';

import '../widgets/language_picker_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/english_digits_formatter.dart';
import '../widgets/auth_text_field.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();

  void _submit() {
    final phone = EnglishDigitsOnlyFormatter.toEnglishDigits(
      _phoneController.text.trim(),
    );
    final l10n = AppLocalizations.of(context)!;

    if (phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.validationPhoneRequired)));
      return;
    }

    if (phone.length < 10) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.validationPhoneEgyptian)));
      return;
    }

    // Add the country code since it's hardcoded in the UI prefix
    final fullPhone = '+20$phone';
    context.read<AuthCubit>().submitPhone(fullPhone);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listenWhen: (prev, curr) =>
              curr is AuthPhoneSubmitted || curr is AuthError,
          listener: (context, state) {
            if (state is AuthPhoneSubmitted) {
              if (ModalRoute.of(context)?.isCurrent == true) {
                context.push('/otp', extra: state.phone);
              }
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
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Top Header: Language Chip & Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/login_logo.png',
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            barrierColor: AppColors.modalBarrierScrim(context),
                            builder: (context) {
                              return const LanguagePickerSheet();
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard(context),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: AppColors.border(context),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                isAr
                                    ? 'assets/images/flag_eg.svg'
                                    : 'assets/images/flag_usa.svg',
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isAr
                                    ? l10n.languageArabicChip
                                    : l10n.languageEnglishChip,
                                style: AppTextStyles.languageChipLabel(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Title and Subtitle
                  Text(
                    l10n.loginPhoneLabel,
                    style: AppTextStyles.screenTitle(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.loginSubtitle,
                    style: AppTextStyles.subtitle(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Phone Input Section
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _phoneController,
                    builder: (context, value, child) {
                      final flagWidget = Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/images/flag_eg.svg',
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+20',
                                style: AppTextStyles.inputText(
                                  context,
                                ).copyWith(color: AppColors.onSurface(context)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 1,
                                height: 16,
                                color: AppColors.border(context),
                              ),
                            ],
                          ),
                        ),
                      );

                      return AuthTextField(
                        controller: _phoneController,
                        label: l10n.loginPhoneLabel,
                        hintText: l10n.loginPhoneHint,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: false,
                          decimal: false,
                        ),
                        textAlign: TextAlign.left,
                        textDirection: TextDirection.ltr,
                        maxLength: 11,
                        inputFormatters: const [
                          EnglishDigitsOnlyFormatter(maxLength: 11),
                        ],
                        prefixIcon: isAr ? null : flagWidget,
                        suffixIcon: isAr ? flagWidget : null,
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Bottom Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.hint(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      elevation: 0,
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
                        : Text(
                            l10n.loginSubmit,
                            style: AppTextStyles.primaryButtonLabel,
                          ),
                  ),
                  const Spacer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
