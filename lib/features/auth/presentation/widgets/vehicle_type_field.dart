import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_media.dart';

/// Custom vehicle-type / dropdown selector matching the Figma design.
///
/// - Label above the field (text-start aligned).
/// - Tappable closed field: hint/value text + arrow.
/// - Opens a ModalBottomSheet on tap to pick from options.
/// - Plays a real [FormField] so validation works with the surrounding [Form].
class VehicleTypeField<T> extends StatelessWidget {
  const VehicleTypeField({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    required this.itemLabelBuilder,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.initialValue,
    this.onChanged,
    this.readOnly = false,
  });

  final String label;
  final String hintText;
  final List<T> items;
  final String Function(T value) itemLabelBuilder;
  final String? Function(T?)? validator;
  final AutovalidateMode autovalidateMode;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final bool readOnly;

  void _showBottomSheet(BuildContext context, FormFieldState<T> field) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final currentSelection = field.value;
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.65,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border(sheetContext),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading4(sheetContext),
                  ),
                ),
                const SizedBox(height: 14),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppColors.border(sheetContext),
                ),
                Flexible(
                  child: items.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              hintText,
                              style: AppTextStyles.inputHint(sheetContext),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            thickness: 0.5,
                            color: AppColors.border(sheetContext),
                          ),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isSelected = item == currentSelection;
                            return InkWell(
                              onTap: () {
                                field.didChange(item);
                                onChanged?.call(item);
                                Navigator.of(sheetContext).pop();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        itemLabelBuilder(item),
                                        textAlign: TextAlign.start,
                                        style: isSelected
                                            ? AppTextStyles.body(context).copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w700,
                                              )
                                            : AppTextStyles.body(context),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.border(context),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: initialValue,
      autovalidateMode: autovalidateMode,
      validator: validator,
      builder: (field) {
        final hasError = field.hasError;
        final borderColor = hasError
            ? AppColors.fieldError(context)
            : AppColors.border(context);
        final selected = field.value;
        final hasValue = selected != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              textAlign: TextAlign.start,
              style: AppTextStyles.fieldLabel(context),
            ),
            const SizedBox(height: 8),
            Material(
              color: readOnly
                  ? AppColors.scaffoldBackground(context)
                  : AppColors.surfaceCard(context),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: readOnly
                    ? null
                    : () => _showBottomSheet(context, field),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: readOnly
                        ? AppColors.scaffoldBackground(context)
                        : AppColors.surfaceCard(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          hasValue
                              ? itemLabelBuilder(selected)
                              : hintText,
                          textAlign: TextAlign.start,
                          style: hasValue
                              ? AppTextStyles.inputText(context).copyWith(
                                  color: readOnly
                                      ? AppColors.paragraph(context)
                                      : AppColors.onSurface(context),
                                )
                              : AppTextStyles.inputHint(context),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      readOnly
                          ? const SizedBox(width: 16, height: 16)
                          : AppSvgImage.asset(
                              AppAssets.icArrowDown,
                              width: 16,
                              height: 16,
                              color: AppColors.paragraph(context),
                            ),
                    ],
                  ),
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 6),
                child: Text(
                  field.errorText ?? '',
                  textAlign: TextAlign.start,
                  style: AppTextStyles.validationCaption,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Generic alias for reusability across all forms
typedef AppDropdownField<T> = VehicleTypeField<T>;
