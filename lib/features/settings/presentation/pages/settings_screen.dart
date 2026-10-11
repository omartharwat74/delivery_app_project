import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/localization/app_locale_scope.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_scope.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_directional_icons.dart';
import '../../../../core/widgets/app_media.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/widgets/app_language_picker_modal.dart';
import '../../../home/presentation/bloc/home_cubit.dart';
import '../../../home/presentation/bloc/home_state.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
import 'verify_phone_otp_args.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().initSettings();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = AppLocaleScope.of(context).locale;
    final themeController = AppThemeScope.of(context);
    final themeMode = themeController.themeMode;
    final isDark = switch (themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => Theme.of(context).brightness == Brightness.dark,
    };

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.goNamed(RouteNames.home);
        }
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<SettingsCubit, SettingsState>(
            listenWhen: (previous, current) {
              return (previous.updateNotificationsSuccess !=
                      current.updateNotificationsSuccess &&
                  current.updateNotificationsSuccess) ||
                  (previous.errorMessage != current.errorMessage &&
                      current.errorMessage != null);
            },
            listener: (context, state) {
              if (state.updateNotificationsSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.settingsUpdatedSuccess,
                      style: AppTextStyles.snackBarMessage(context),
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
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
              }
            },
          ),
          BlocListener<HomeCubit, HomeState>(
            listenWhen: (previous, current) =>
                current is HomeAvailabilityError ||
                current is HomeAvailabilitySuccess,
            listener: (context, state) {
              if (state is HomeAvailabilityError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: AppTextStyles.snackBarMessage(context),
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else if (state is HomeAvailabilitySuccess && state.message != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message!,
                      style: AppTextStyles.snackBarMessage(context),
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
        final notificationsEnabled = state.isNotify;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground(context),
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    _SettingsHeader(title: l10n.generalSettingsTitle),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Column(
                        children: [
                          _SettingsRow(
                            iconAsset: AppAssets.generalSettingsLanguage,
                            title: l10n.changeAppLanguage,
                            trailing: _LanguageTrailing(
                              label: locale.languageCode == 'ar'
                                  ? l10n.arabicLanguage
                                  : l10n.englishLanguage,
                            ),
                            onTap: () => showAppLanguagePicker(context),
                          ),
                          _SettingsDivider(),
                          _SettingsRow(
                            iconAsset: AppAssets.generalSettingsChangePhone,
                            title: l10n.changePhoneNumber,
                            trailing: SizedBox(
                              width: 24,
                              height: 28,
                              child: Icon(
                                Icons.chevron_right_rounded,
                                size: 24,
                                color: AppColors.paragraph(context),
                              ),
                            ),
                            onTap: () {
                              final currentPhone =
                                  state.driver?.phone ?? state.currentPhone ?? '';
                              context.pushNamed(
                                RouteNames.verifyPhoneOtp,
                                extra: VerifyPhoneOtpArgs(
                                  phoneNumber: currentPhone,
                                  isCurrentPhone: true,
                                ),
                              );
                            },
                          ),
                          _SettingsDivider(),
                          Builder(
                            builder: (ctx) {
                              HomeState? homeState;
                              try {
                                homeState = ctx.watch<HomeCubit>().state;
                              } catch (_) {
                                homeState = null;
                              }

                              final isOnline = homeState != null
                                  ? homeState.isOnline
                                  : (state.driver?.isOnline ?? false);
                              final isLoadingAvailability =
                                  homeState is HomeAvailabilityLoading;

                              return _SettingsRow(
                                iconAsset: AppAssets.generalSettingsManageOrders,
                                title: l10n.manageOrderReception,
                                trailing: _NotificationSwitch(
                                  value: isOnline,
                                  onChanged: isLoadingAvailability
                                      ? (_) {}
                                      : (value) {
                                          try {
                                            ctx.read<HomeCubit>().toggleAvailability(value);
                                          } catch (_) {}
                                        },
                                ),
                              );
                            },
                          ),
                          _SettingsDivider(),
                          _SettingsRow(
                            iconAsset: AppAssets.generalSettingsNotifications,
                            title: l10n.notificationsControl,
                            trailing: _NotificationSwitch(
                              value: notificationsEnabled,
                              onChanged: (value) {
                                context.read<SettingsCubit>().toggleNotifications(value);
                              },
                            ),
                          ),
                          _SettingsDivider(),
                          _SettingsRow(
                            iconAsset: AppAssets.generalSettingsDarkMode,
                            title: l10n.darkMode,
                            trailing: _DarkModeSwitch(
                              value: isDark,
                              onChanged: (value) {
                                themeController.setThemeMode(
                                  value ? ThemeMode.dark : ThemeMode.light,
                                );
                              },
                            ),
                          ),
                          _SettingsDivider(),
                          _SettingsRow(
                            iconAsset: AppAssets.generalSettingsDeleteAccount,
                            title: l10n.deleteAccount,
                            titleColor: AppColors.error,
                            onTap: () => _showDeleteAccountDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (state.isLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black26,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  ),
);
}

  Future<void> _showDeleteAccountDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAccountConfirmationTitle),
        content: Text(l10n.deleteAccountConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthCubit>().logout();
              context.go(RouteNames.login);
            },
            child: Text(
              l10n.confirm,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
        ),
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(RouteNames.home);
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
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: AppTextStyles.appBarTitle(context).copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTrailing extends StatelessWidget {
  const _LanguageTrailing({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body(context).copyWith(
            color: AppColors.paragraph(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 24,
          height: 28,
          child: Icon(
            Icons.chevron_right_rounded,
            size: 24,
            color: AppColors.paragraph(context),
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.iconAsset,
    required this.title,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  final String iconAsset;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            AppSvgImage.asset(iconAsset, width: 32, height: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: AppTextStyles.body(context).copyWith(
                  color: titleColor ?? AppColors.onSurface(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 0.5, color: AppColors.border(context));
  }
}

class _NotificationSwitch extends StatelessWidget {
  const _NotificationSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final trackColor = value
        ? AppColors.success
        : Theme.of(context).brightness == Brightness.dark
            ? AppColors.settingsDarkTrack
            : AppColors.settingsLightTrack;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Semantics(
        toggled: value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 56,
          height: 28,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: value
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.text,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.12),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkModeSwitch extends StatelessWidget {
  const _DarkModeSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Semantics(
        toggled: value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 56,
          height: 28,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppColors.text,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.settingsSwitchBorder,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerLeft : Alignment.centerRight,
            child: _DarkModeSwitchKnob(value: value),
          ),
        ),
      ),
    );
  }
}

class _DarkModeSwitchKnob extends StatelessWidget {
  const _DarkModeSwitchKnob({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: value ? AppColors.darkModeKnobOn : AppColors.darkModeKnobOff,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        value ? Icons.nightlight_round : Icons.wb_sunny_rounded,
        size: 16,
        color: value ? AppColors.text : AppColors.sunIcon,
      ),
    );
  }
}
