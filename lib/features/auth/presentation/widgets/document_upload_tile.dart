import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/localization/context_locale_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_media.dart';
import '../../../../core/widgets/dashed_border.dart';
import '../../../../l10n/app_localizations.dart';

/// Document upload section: a dashed picker that stays visible at all times,
/// plus an animated success card revealed below when a file is selected.
class DocumentUploadTile extends StatelessWidget {
  const DocumentUploadTile({
    super.key,
    required this.label,
    required this.hintText,
    required this.tapToUploadLabel,
    required this.onTap,
    required this.onRemove,
    this.imageFile,
    this.imageUrl,
    this.errorText,
    this.hasError = false,
    this.readOnly = false,
  });

  final String label;
  final String hintText;
  final String tapToUploadLabel;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final File? imageFile;
  final String? imageUrl;
  final String? errorText;
  final bool hasError;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.start,
          style: AppTextStyles.fieldLabel(context),
        ),
        const SizedBox(height: 8),
        if (!readOnly)
          _DashedUploadBox(
            hintText: hintText,
            tapToUploadLabel: tapToUploadLabel,
            hasError: hasError,
            onTap: onTap,
          ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              alignment: Alignment.topCenter,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: AlignmentDirectional.topStart,
            children: [...previousChildren, ?currentChild],
          ),
          child: imageFile != null
              ? Padding(
                  key: ValueKey('success_${imageFile!.path}'),
                  padding: EdgeInsets.only(top: readOnly ? 0 : 12),
                  child: UploadSuccessCard(
                    imageFile: imageFile!,
                    onDelete: onRemove,
                    readOnly: readOnly,
                  ),
                )
              : (imageUrl != null && imageUrl!.trim().isNotEmpty)
                  ? Padding(
                      key: ValueKey('success_url_${imageUrl!}'),
                      padding: EdgeInsets.only(top: readOnly ? 0 : 12),
                      child: NetworkUploadSuccessCard(
                        imageUrl: imageUrl!,
                        onDelete: onRemove,
                        readOnly: readOnly,
                      ),
                    )
                  : readOnly
                      ? const Padding(
                          key: ValueKey('mock_view_card'),
                          padding: EdgeInsets.only(top: 8),
                          child: _MockViewModeBox(),
                        )
                      : const SizedBox(
                          key: ValueKey('upload_card_empty'),
                          width: double.infinity,
                        ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 6),
            child: Text(errorText!, style: AppTextStyles.validationCaption),
          ),
      ],
    );
  }
}

class _MockViewModeBox extends StatelessWidget {
  const _MockViewModeBox();

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        width: double.infinity,
        height: 88,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border(context), width: 0.5),
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/mock_license.png',
              height: 65,
              width: 65,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedUploadBox extends StatelessWidget {
  const _DashedUploadBox({
    required this.hintText,
    required this.tapToUploadLabel,
    required this.hasError,
    required this.onTap,
  });

  final String hintText;
  final String tapToUploadLabel;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;
    final strokeColor = AppColors.documentUploadStroke(context);
    final borderColor = hasError ? AppColors.fieldError(context) : strokeColor;

    return Material(
      color: AppColors.surfaceCard(context),
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: DashedBorder(
          color: borderColor,
          borderRadius: 10,
          child: SizedBox(
            height: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                AppSvgImage.asset(
                  AppAssets.icFileUpload,
                  width: 20,
                  height: 20,
                  color: const Color(0xFFB6B6B6), // Hardcoded #B6B6B6
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: hintText,
                        style: AppTextStyles.uploadHint(context),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: tapToUploadLabel,
                        style: AppTextStyles.uploadAction(context),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  textDirection: textDirection,
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

class UploadSuccessCard extends StatelessWidget {
  const UploadSuccessCard({
    super.key,
    required this.imageFile,
    required this.onDelete,
    this.readOnly = false,
  });

  final File imageFile;
  final VoidCallback onDelete;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = context.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        height: 88,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border(context), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (!readOnly) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  imageFile,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.uploadSuccessAdded,
                            textAlign: TextAlign.start,
                            style: AppTextStyles.inputText(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _DeleteIconButton(onPressed: onDelete),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: 1,
                        minHeight: 6,
                        backgroundColor: AppColors.success.withValues(
                          alpha: 0.15,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  imageFile,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeleteIconButton extends StatelessWidget {
  const _DeleteIconButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: AppSvgImage.asset(
        AppAssets.icDelete,
        width: 20,
        height: 20,
        color: AppColors.primary,
      ),
    );
  }
}

class NetworkUploadSuccessCard extends StatelessWidget {
  const NetworkUploadSuccessCard({
    super.key,
    required this.imageUrl,
    required this.onDelete,
    this.readOnly = false,
  });

  final String imageUrl;
  final VoidCallback onDelete;
  final bool readOnly;

  String _resolveUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return 'https://mycar.msarweb.net$trimmed';
    }
    return 'https://mycar.msarweb.net/$trimmed';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = context.isArabic;
    final resolved = _resolveUrl(imageUrl);

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        height: 88,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border(context), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (!readOnly) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: resolved,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder: (c, u) => Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.shade200,
                  ),
                  errorWidget: (c, u, e) => Image.asset(
                    'assets/images/mock_license.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.uploadSuccessAdded,
                            textAlign: TextAlign.start,
                            style: AppTextStyles.inputText(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _DeleteIconButton(onPressed: onDelete),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: 1,
                        minHeight: 6,
                        backgroundColor: AppColors.success.withValues(
                          alpha: 0.15,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: resolved,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                  placeholder: (c, u) => Container(
                    width: 65,
                    height: 65,
                    color: Colors.grey.shade200,
                  ),
                  errorWidget: (c, u, e) => Image.asset(
                    'assets/images/mock_license.png',
                    width: 65,
                    height: 65,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
