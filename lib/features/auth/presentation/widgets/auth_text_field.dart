import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool readOnly;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final InputBorder? border;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final AutovalidateMode? autovalidateMode;

  const AuthTextField({
    super.key,
    required this.controller,
    this.label,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.maxLength,
    this.inputFormatters,
    this.border,
    this.textAlign,
    this.textDirection,
    this.autovalidateMode,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    if (widget.controller.text.isNotEmpty) {
      widget.controller.selection = TextSelection.collapsed(
        offset: widget.controller.text.length,
      );
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && widget.controller.text.isNotEmpty) {
      widget.controller.selection = TextSelection.collapsed(
        offset: widget.controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  TextDirection? _getDirection(String text) {
    if (text.isEmpty) return null;
    final isEnglish = RegExp(r'^[a-zA-Z0-9]').hasMatch(text);
    return isEnglish ? TextDirection.ltr : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTextStyles.fieldLabel(context)),
          const SizedBox(height: 8),
        ],
        TextFormField(
          focusNode: _focusNode,
          enabled: widget.enabled,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          textAlign: widget.textAlign ?? TextAlign.start,
          style: AppTextStyles.inputText(context).copyWith(
            color: widget.readOnly
                ? AppColors.paragraph(context)
                : AppColors.onSurface(context),
          ),
          cursorColor: AppColors.cursor(context),
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          textDirection:
              widget.textDirection ?? _getDirection(widget.controller.text),
          onChanged: (val) {
            setState(() {});
          },
          onTap: () {
            if (widget.controller.text.isNotEmpty) {
              widget.controller.selection = TextSelection.fromPosition(
                TextPosition(offset: widget.controller.text.length),
              );
            }
          },
          onTapOutside: (_) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          buildCounter: widget.maxLength != null
              ? (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) => null
              : null,
          decoration: InputDecoration(
            counterText: widget.maxLength != null ? '' : null,
            hintText: widget.hintText,
            hintStyle: AppTextStyles.inputHint(context),
            filled: true,
            fillColor: widget.readOnly
                ? AppColors.scaffoldBackground(context)
                : AppColors.surfaceCard(context),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder:
                widget.border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.border(context),
                    width: 0.5,
                  ),
                ),
            focusedBorder:
                widget.border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.fieldFocusBorder(context),
                    width: 0.5,
                  ),
                ),
            errorBorder:
                widget.border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.fieldError(context),
                    width: 0.5,
                  ),
                ),
            focusedErrorBorder:
                widget.border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.fieldError(context),
                    width: 0.5,
                  ),
                ),
          ),
        ),
      ],
    );
  }
}
