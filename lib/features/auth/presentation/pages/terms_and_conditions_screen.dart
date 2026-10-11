import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app_project/core/theme/app_colors.dart';
import 'package:delivery_app_project/core/theme/text_styles.dart';
import 'package:delivery_app_project/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:delivery_app_project/features/settings/presentation/bloc/settings_state.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  static String stripHtml(String html) {
    if (html.isEmpty) return '';
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bg = AppColors.scaffoldBackground(context);
    final fg = AppColors.onSurface(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        leading: BackButton(color: fg, onPressed: () => context.pop()),
        title: Text(l10n.termsTitle, style: AppTextStyles.appBarTitle(context)),
        centerTitle: false,
        titleSpacing: 4.0,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state.isTermsLoading && state.terms == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.termsErrorMessage != null &&
              (state.terms == null || state.terms!.trim().isEmpty)) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.termsErrorMessage!,
                      style: AppTextStyles.body(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<SettingsCubit>().loadTerms(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(l10n.confirm),
                    ),
                  ],
                ),
              ),
            );
          }

          final rawTerms = state.terms;
          final displayText = (rawTerms != null && rawTerms.trim().isNotEmpty)
              ? stripHtml(rawTerms)
              : l10n.termsBody;

          return RefreshIndicator(
            onRefresh: () => context.read<SettingsCubit>().loadTerms(),
            color: AppColors.primary,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 32),
                child: Container(
                  width: double.infinity,
                  alignment: AlignmentDirectional.topStart,
                  child: Text(
                    displayText,
                    textAlign: TextAlign.start,
                    textDirection: Directionality.of(context),
                    style: AppTextStyles.termsBody(context),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
