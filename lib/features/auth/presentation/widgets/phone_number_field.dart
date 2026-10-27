import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_media.dart';

/// Phone field with Egypt +20 prefix locked on the physical LEFT (LTR island).
class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.readOnly = false,
    this.trailingLabel,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;
  final bool readOnly;
  final Widget? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              textAlign: TextAlign.start,
              style: AppTextStyles.fieldLabel(context),
            ),
            ?trailingLabel,
          ],
        ),
        const SizedBox(height: 8),
        FormField<String>(
          key: key,
          validator: (_) => validator?.call(controller.text),
          autovalidateMode: autovalidateMode,
          builder: (field) {
            final borderColor = field.hasError
                ? AppColors.fieldError(context)
                : AppColors.border(context);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: readOnly
                        ? AppColors.scaffoldBackground(context)
                        : AppColors.surfaceCard(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      children: [
                        _PhoneCountryPrefix(readOnly: readOnly),
                        Expanded(
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: controller,
                              builder: (context, value, child) {
                                return TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.phone,
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.start,
                                  style: AppTextStyles.inputText(context)
                                      .copyWith(
                                        color: readOnly
                                            ? AppColors.paragraph(context)
                                            : AppColors.onSurface(context),
                                      ),
                                  readOnly: readOnly,
                                  cursorColor: AppColors.cursor(context),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    hintText: hintText,
                                    hintStyle: AppTextStyles.inputHint(context),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                    isDense: true,
                                  ),
                                  onChanged: field.didChange,
                                  onTapOutside: (_) =>
                                      FocusScope.of(context).unfocus(),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 6),
                    child: Text(
                      field.errorText ?? '',
                      style: AppTextStyles.validationCaption,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Flag + +20 + divider (parent [Row] is forced LTR).
class _PhoneCountryPrefix extends StatelessWidget {
  final bool readOnly;

  const _PhoneCountryPrefix({this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgImage.asset(AppAssets.flagEg, width: 16, height: 16),
          const SizedBox(width: 4),
          Text(
            '+20',
            style: AppTextStyles.inputText(
              context,
            ).copyWith(
              color: readOnly
                  ? AppColors.paragraph(context)
                  : AppColors.onSurface(context),
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 16, color: AppColors.border(context)),
        ],
      ),
    );
  }
}
