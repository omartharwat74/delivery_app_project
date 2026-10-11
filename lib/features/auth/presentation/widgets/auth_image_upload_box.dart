import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:dotted_border/dotted_border.dart';

/// Profile-photo style upload box with dashed border.
///
/// - Displays dashed square box using [DottedBorder].
/// - When [imageFile] is null, displays [imageAsset] (default: profile placeholder).
/// - When [imageFile] is provided, displays [imageFile] using [Image.file] inside [ClipRRect].
/// - If [showUploadIcon] is true, overlays the upload icon.
class AuthImageUploadBox extends StatelessWidget {
  const AuthImageUploadBox({
    super.key,
    required this.imageFile,
    required this.onTap,
    this.hasError = false,
    this.size = 100,
    this.borderRadius = 12,
    this.readOnly = false,
    this.imageAsset = AppAssets.profilePlaceholder,
    this.showUploadIcon = true,
  });

  final File? imageFile;
  final VoidCallback onTap;
  final bool hasError;
  final double size;
  final double borderRadius;
  final bool readOnly;
  final String? imageAsset;
  final bool showUploadIcon;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageFile != null;
    final borderColor = hasError
        ? AppColors.fieldError(context)
        : const Color(0xFFA3090F);

    final resolvedAsset = imageAsset ?? AppAssets.profilePlaceholder;

    return GestureDetector(
      onTap: readOnly ? null : onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: Radius.circular(borderRadius),
          dashPattern: const <double>[8, 4],
          strokeWidth: 2.0,
          color: readOnly ? Colors.transparent : borderColor,
          padding: EdgeInsets.zero,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  Image.file(imageFile!, fit: BoxFit.cover)
                else if (resolvedAsset.isNotEmpty)
                  Image.asset(resolvedAsset, fit: BoxFit.cover)
                else if (readOnly)
                  Container(
                    color: AppColors.scaffoldBackground(context),
                    child: Icon(
                      Icons.person,
                      size: size * 0.5,
                      color:
                          AppColors.paragraph(context).withValues(alpha: 0.5),
                    ),
                  ),
                if (showUploadIcon && !readOnly) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: hasImage
                          ? Colors.black.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.22),
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      AppAssets.profileImageUploadIcon,
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
