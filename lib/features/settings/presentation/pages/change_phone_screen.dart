import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/english_digits_formatter.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../core/widgets/app_directional_icons.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
import 'verify_phone_otp_args.dart';

class ChangePhoneScreen extends StatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  State<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {
  late final TextEditingController _phoneController;
  late final FocusNode _phoneFocusNode;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _phoneFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _phoneFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _confirmPhone() {
    FocusManager.instance.primaryFocus?.unfocus();
    final l10n = AppLocalizations.of(context)!;
    final phone = _phoneController.text.trim().formatAsEgyptianPhone();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.invalidPhoneMessage,
            style: AppTextStyles.snackBarMessage(context),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final hasValidLength = phone.length == 11 || phone.length == 12;
    if (!hasValidLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.invalidPhoneLengthMessage,
            style: AppTextStyles.snackBarMessage(context),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<SettingsCubit>().sendNewPhoneOtp(phone);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.scaffoldBackground(context),
      body: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (prev, curr) =>
            curr.sendNewOtpSuccess != prev.sendNewOtpSuccess ||
            curr.errorMessage != prev.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
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
          } else if (state.sendNewOtpSuccess) {
            context.pushReplacementNamed(
              RouteNames.verifyPhoneOtp,
              extra: VerifyPhoneOtpArgs(
                phoneNumber: _phoneController.text.trim(),
                isCurrentPhone: false,
                newPhoneNumber: _phoneController.text.trim(),
              ),
            );
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const _PhoneFlowBackHeader(),
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
                              _PhoneFlowIntro(
                                title: l10n.changePhoneTitle,
                                subtitle: l10n.changePhoneSubtitle,
                              ),
                              const SizedBox(height: 24),
                              _PhoneNumberField(
                                label: l10n.mobileNumber,
                                hint: l10n.mobileNumber,
                                controller: _phoneController,
                                focusNode: _phoneFocusNode,
                              ),
                              const SizedBox(height: 16),
                              BlocBuilder<SettingsCubit, SettingsState>(
                                builder: (context, state) {
                                  return _ConfirmButton(
                                    label: l10n.confirm,
                                    isLoading: state.isLoading,
                                    onTap: state.isLoading ? () {} : _confirmPhone,
                                  );
                                },
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

class _PhoneFlowBackHeader extends StatelessWidget {
  const _PhoneFlowBackHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 20),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteNames.settings);
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

class _PhoneFlowIntro extends StatelessWidget {
  const _PhoneFlowIntro({required this.title, required this.subtitle});

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

class _PhoneNumberField extends StatelessWidget {
  const _PhoneNumberField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.start,
          style: AppTextStyles.fieldLabel(context).copyWith(
            color: AppColors.onSurface(context),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border(context), width: 0.5),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                _EgyptPhonePrefix(),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: false,
                      decimal: false,
                    ),
                    textInputAction: TextInputAction.done,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    maxLength: 11,
                    inputFormatters: const [
                      EnglishDigitsOnlyFormatter(maxLength: 11),
                    ],
                    cursorColor: AppColors.cursor(context),
                    style: AppTextStyles.inputText(context).copyWith(
                      color: AppColors.onSurface(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      isDense: true,
                      hintText: hint,
                      hintStyle: AppTextStyles.inputHint(context).copyWith(
                        color: AppColors.hint(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EgyptPhonePrefix extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(AppAssets.flagEg, width: 16, height: 16),
            const SizedBox(width: 4),
            Text(
              '+20',
              style: AppTextStyles.inputText(context).copyWith(
                color: AppColors.onSurface(context),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Container(width: 0.5, height: 15.5, color: AppColors.border(context)),
      ],
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.all(AppRadius.sm),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.text,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.primaryButtonLabel.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
      ),
    );
  }
}
