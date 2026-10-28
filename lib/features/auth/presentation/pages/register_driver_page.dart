import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/localization/context_locale_ext.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/auth_form_validation.dart';
import '../../../../core/utils/auth_validators.dart';
import '../../../../core/widgets/app_success_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../bloc/lookups_cubit.dart';
import '../bloc/lookups_state.dart';
import '../widgets/app_language_picker_modal.dart';
import '../widgets/auth_image_upload_box.dart';
import '../widgets/auth_language_chip.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/document_upload_tile.dart';
import '../widgets/phone_number_field.dart';
import '../widgets/vehicle_type_field.dart';

enum _MediaSlot {
  profile,
  driverLicense,
  vehicleLicense,
  nationalId,
  vehicleFront,
}

class RegisterDriverPage extends StatefulWidget {
  final String? phone;
  const RegisterDriverPage({super.key, this.phone});

  @override
  State<RegisterDriverPage> createState() => _RegisterDriverPageState();
}

class _RegisterDriverPageState extends State<RegisterDriverPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _picker = ImagePicker();

  int? _selectedAreaId;
  int? _selectedShiftId;
  String? _vehicleType;
  File? _profilePhotoFile;
  File? _driverLicensePhotoFile;
  File? _vehicleLicensePhotoFile;
  File? _nationalIdPhotoFile;
  File? _vehicleFrontPhotoFile;
  bool _hasAttemptedSubmit = false;
  bool _hasHandledSuccess = false;

  static const _vehicleTypes = ['motorcycle', 'regular_bike'];

  @override
  void initState() {
    super.initState();
    _initPhone();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.read<LookupsCubit>().fetchAllLookups();
        } catch (_) {}
      }
    });
  }

  void _initPhone() {
    var phone = widget.phone ?? context.read<AuthCubit>().phoneNumber ?? '';
    phone = phone.replaceAll(RegExp(r'\D'), '');
    if (phone.startsWith('20')) {
      phone = phone.substring(2);
    }
    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }
    _phoneController.text = phone;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  String _vehicleLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'motorcycle':
        return l10n.vehicleTypeMotorcycle;
      case 'regular_bike':
      case 'bicycle':
        return l10n.vehicleTypeBicycle;
      default:
        return key;
    }
  }

  Future<File?> _pickImageFile() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    return File(picked.path);
  }

  String _apiPhoneNumber() {
    var digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('20')) {
      digits = digits.substring(2);
    }
    if (!digits.startsWith('0')) {
      digits = '0$digits';
    }
    return digits;
  }

  void _onMediaChanged(_MediaSlot slot, File? file) {
    setState(() {
      switch (slot) {
        case _MediaSlot.profile:
          _profilePhotoFile = file;
          break;
        case _MediaSlot.driverLicense:
          _driverLicensePhotoFile = file;
          break;
        case _MediaSlot.vehicleLicense:
          _vehicleLicensePhotoFile = file;
          break;
        case _MediaSlot.nationalId:
          _nationalIdPhotoFile = file;
          break;
        case _MediaSlot.vehicleFront:
          _vehicleFrontPhotoFile = file;
          break;
      }
    });
  }

  void _onRegisterPressed() {
    FocusScope.of(context).unfocus();

    if (!_hasAttemptedSubmit) {
      setState(() => _hasAttemptedSubmit = true);
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    final l10n = AppLocalizations.of(context)!;

    if (!isValid ||
        _profilePhotoFile == null ||
        _driverLicensePhotoFile == null ||
        _vehicleLicensePhotoFile == null ||
        _nationalIdPhotoFile == null ||
        _vehicleFrontPhotoFile == null ||
        _vehicleType == null ||
        _selectedAreaId == null ||
        _selectedShiftId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.validationFormCheckErrors,
            style: AppTextStyles.snackBarMessage(context),
          ),
          backgroundColor: AppColors.fieldError(context),
        ),
      );
      return;
    }

    context.read<AuthCubit>().registerDriver(
      name: _usernameController.text.trim(),
      phone: _apiPhoneNumber(),
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      nationalId: _nationalIdController.text.trim().isNotEmpty
          ? _nationalIdController.text.trim()
          : null,
      vehicleType: _vehicleType!,
      areaId: _selectedAreaId.toString(),
      shiftId: _selectedShiftId.toString(),
      image: _profilePhotoFile!,
      drivingLicense: _driverLicensePhotoFile!,
      vehicleLicense: _vehicleLicensePhotoFile!,
      nationalIdImage: _nationalIdPhotoFile!,
      vehicleFront: _vehicleFrontPhotoFile!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fieldAutovalidate = authAutovalidateMode(_hasAttemptedSubmit);

    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (prev, curr) =>
          curr is AuthRegistrationPending ||
          curr is AuthRegistrationSubmitted ||
          curr is AuthError,
      listener: (context, state) async {
        if (state is AuthRegistrationPending ||
            state is AuthRegistrationSubmitted) {
          if (_hasHandledSuccess) return;
          _hasHandledSuccess = true;

          final message = (state is AuthRegistrationPending &&
                  state.message.isNotEmpty)
              ? state.message
              : l10n.registrationPendingMessage;

          await AppSuccessDialog.show(
            context,
            message: message,
          );

          if (context.mounted) {
            context.read<AuthCubit>().reset();
            context.go(RouteNames.login);
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
        final isSubmitting = state is AuthLoading;
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground(context),
          bottomNavigationBar: SafeArea(
            child: Container(
              color: AppColors.surfaceCard(context),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: AuthPrimaryButton(
                label: l10n.registerSubmit,
                onPressed: isSubmitting ? null : _onRegisterPressed,
              ),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.registerWelcomeTitle,
                                textAlign: TextAlign.start,
                                style: AppTextStyles.screenTitle(context),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.registerWelcomeSubtitle,
                                textAlign: TextAlign.start,
                                style: AppTextStyles.subtitle(context),
                              ),
                            ],
                          ),
                        ),
                        AuthLanguageChip(
                          label: context.isArabic
                              ? l10n.languageArabicChip
                              : l10n.languageEnglishChip,
                          flagAsset: context.isArabic
                              ? AppAssets.flagEg
                              : AppAssets.flagUsa,
                          onTap: () => showAppLanguagePicker(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _ProfilePhotoFormField(
                      fieldKey: const ValueKey('register_profile_photo'),
                      initialValue: _profilePhotoFile,
                      label: l10n.registerProfilePhotoLabel,
                      requiredMessage: l10n.validationProfilePhotoRequired,
                      autovalidateMode: fieldAutovalidate,
                      onPick: _pickImageFile,
                      onChanged: (file) =>
                          _onMediaChanged(_MediaSlot.profile, file),
                    ),
                    const SizedBox(height: 20),
                    AuthTextField(
                      key: const ValueKey('register_username'),
                      controller: _usernameController,
                      label: l10n.registerUsernameLabel,
                      hintText: l10n.registerUsernameHint,
                      autovalidateMode: fieldAutovalidate,
                      validator: (v) => AuthValidators.usernameRegister(
                        v,
                        requiredMessage: l10n.validationUsernameRequired,
                        minMessage: l10n.validationUsernameMin3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    PhoneNumberField(
                      key: const ValueKey('register_phone'),
                      controller: _phoneController,
                      label: l10n.registerPhoneLabel,
                      hintText: l10n.registerPhoneHint,
                      readOnly: true,
                      autovalidateMode: fieldAutovalidate,
                      validator: (v) => AuthValidators.egyptianPhone(
                        v,
                        requiredMessage: l10n.validationPhoneRequired,
                        invalidMessage: l10n.validationPhoneEgyptian,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AuthTextField(
                      key: const ValueKey('register_email'),
                      controller: _emailController,
                      label: l10n.registerEmailLabel,
                      hintText: l10n.registerEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: fieldAutovalidate,
                      validator: (v) => AuthValidators.emailBasic(
                        v,
                        requiredMessage: l10n.validationEmailRequired,
                        invalidMessage: l10n.validationEmailInvalid,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AuthTextField(
                      key: const ValueKey('register_national_id'),
                      controller: _nationalIdController,
                      label: l10n.registerNationalIdLabel,
                      hintText: l10n.registerNationalIdHint,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      autovalidateMode: fieldAutovalidate,
                      validator: (v) => AuthValidators.egyptianNationalId(
                        v,
                        requiredMessage: l10n.validationNationalIdRequired,
                        invalidMessage: l10n.validationNationalIdInvalid,
                      ),
                    ),
                    const SizedBox(height: 20),
                    VehicleTypeField<String>(
                      key: const ValueKey('register_vehicle_type'),
                      label: l10n.registerVehicleTypeLabel,
                      hintText: l10n.registerVehicleTypeHint,
                      items: _vehicleTypes,
                      itemLabelBuilder: (t) => _vehicleLabel(l10n, t),
                      initialValue: _vehicleType,
                      autovalidateMode: fieldAutovalidate,
                      validator: (v) => AuthValidators.requiredSelection(
                        v,
                        requiredMessage: l10n.validationVehicleTypeRequired,
                      ),
                      onChanged: (v) => setState(() => _vehicleType = v),
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<LookupsCubit, LookupsState>(
                      builder: (context, lookupsState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            VehicleTypeField<int>(
                              key: const ValueKey('register_delivery_area'),
                              label: l10n.registerDeliveryAreaLabel,
                              hintText: lookupsState.isLoadingAreas
                                  ? '...'
                                  : l10n.registerDeliveryAreaHint,
                              items:
                                  lookupsState.areas.map((a) => a.id).toList(),
                              itemLabelBuilder: (id) {
                                final matches =
                                    lookupsState.areas.where((a) => a.id == id);
                                return matches.isNotEmpty
                                    ? matches.first.name
                                    : '';
                              },
                              initialValue: _selectedAreaId,
                              autovalidateMode: fieldAutovalidate,
                              validator: (v) => v == null
                                  ? l10n.validationAreaRequired
                                  : null,
                              onChanged: (id) =>
                                  setState(() => _selectedAreaId = id),
                            ),
                            const SizedBox(height: 20),
                            VehicleTypeField<int>(
                              key: const ValueKey('register_delivery_shift'),
                              label: l10n.registerDeliveryShiftLabel,
                              hintText: lookupsState.isLoadingShifts
                                  ? '...'
                                  : l10n.registerDeliveryShiftHint,
                              items:
                                  lookupsState.shifts.map((s) => s.id).toList(),
                              itemLabelBuilder: (id) {
                                final matches = lookupsState.shifts
                                    .where((s) => s.id == id);
                                return matches.isNotEmpty
                                    ? matches.first.displayLabel
                                    : '';
                              },
                              initialValue: _selectedShiftId,
                              autovalidateMode: fieldAutovalidate,
                              validator: (v) => v == null
                                  ? l10n.validationShiftRequired
                                  : null,
                              onChanged: (id) =>
                                  setState(() => _selectedShiftId = id),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _DocumentUploadFormField(
                      fieldKey: const ValueKey('register_driving_license'),
                      initialValue: _driverLicensePhotoFile,
                      label: l10n.registerUploadDrivingLicense,
                      hintText: l10n.registerUploadDrivingLicense,
                      tapToUploadLabel: l10n.uploadTapToUpload,
                      requiredMessage: l10n.validationDocumentRequired,
                      autovalidateMode: fieldAutovalidate,
                      onPick: _pickImageFile,
                      onChanged: (file) =>
                          _onMediaChanged(_MediaSlot.driverLicense, file),
                    ),
                    const SizedBox(height: 20),
                    _DocumentUploadFormField(
                      fieldKey: const ValueKey('register_vehicle_license'),
                      initialValue: _vehicleLicensePhotoFile,
                      label: l10n.registerUploadVehicleLicense,
                      hintText: l10n.registerUploadVehicleLicense,
                      tapToUploadLabel: l10n.uploadTapToUpload,
                      requiredMessage: l10n.validationDocumentRequired,
                      autovalidateMode: fieldAutovalidate,
                      onPick: _pickImageFile,
                      onChanged: (file) =>
                          _onMediaChanged(_MediaSlot.vehicleLicense, file),
                    ),
                    const SizedBox(height: 20),
                    _DocumentUploadFormField(
                      fieldKey: const ValueKey('register_national_id_doc'),
                      initialValue: _nationalIdPhotoFile,
                      label: l10n.registerUploadNationalId,
                      hintText: l10n.registerUploadNationalId,
                      tapToUploadLabel: l10n.uploadTapToUpload,
                      requiredMessage: l10n.validationDocumentRequired,
                      autovalidateMode: fieldAutovalidate,
                      onPick: _pickImageFile,
                      onChanged: (file) =>
                          _onMediaChanged(_MediaSlot.nationalId, file),
                    ),
                    const SizedBox(height: 20),
                    _DocumentUploadFormField(
                      fieldKey: const ValueKey('register_vehicle_front'),
                      initialValue: _vehicleFrontPhotoFile,
                      label: l10n.registerUploadVehicleFront,
                      hintText: l10n.registerUploadVehicleFront,
                      tapToUploadLabel: l10n.uploadTapToUpload,
                      requiredMessage: l10n.validationVehicleFrontRequired,
                      autovalidateMode: fieldAutovalidate,
                      onPick: _pickImageFile,
                      onChanged: (file) =>
                          _onMediaChanged(_MediaSlot.vehicleFront, file),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfilePhotoFormField extends StatelessWidget {
  const _ProfilePhotoFormField({
    required this.fieldKey,
    required this.label,
    required this.requiredMessage,
    required this.autovalidateMode,
    required this.onPick,
    required this.onChanged,
    this.initialValue,
  });

  final Key fieldKey;
  final String label;
  final String requiredMessage;
  final AutovalidateMode autovalidateMode;
  final Future<File?> Function() onPick;
  final ValueChanged<File?> onChanged;
  final File? initialValue;

  @override
  Widget build(BuildContext context) {
    return FormField<File>(
      key: fieldKey,
      initialValue: initialValue,
      autovalidateMode: autovalidateMode,
      validator: (file) => (file ?? initialValue) == null ? requiredMessage : null,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.fieldLabel(context),
              ),
            ),
            const SizedBox(height: 8),
            AuthImageUploadBox(
              imageFile: field.value ?? initialValue,
              imageAsset: AppAssets.profilePlaceholder,
              hasError: field.hasError,
              showUploadIcon: true,
              onTap: () async {
                final file = await onPick();
                if (file != null) {
                  field.didChange(file);
                  onChanged(file);
                }
              },
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 6),
                child: Text(
                  field.errorText ?? '',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.validationCaption,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DocumentUploadFormField extends StatelessWidget {
  const _DocumentUploadFormField({
    required this.fieldKey,
    required this.label,
    required this.hintText,
    required this.tapToUploadLabel,
    required this.requiredMessage,
    required this.autovalidateMode,
    required this.onPick,
    required this.onChanged,
    this.initialValue,
  });

  final Key fieldKey;
  final String label;
  final String hintText;
  final String tapToUploadLabel;
  final String requiredMessage;
  final AutovalidateMode autovalidateMode;
  final Future<File?> Function() onPick;
  final ValueChanged<File?> onChanged;
  final File? initialValue;

  @override
  Widget build(BuildContext context) {
    return FormField<File>(
      key: fieldKey,
      initialValue: initialValue,
      autovalidateMode: autovalidateMode,
      validator: (file) => (file ?? initialValue) == null ? requiredMessage : null,
      builder: (field) {
        return DocumentUploadTile(
          label: label,
          hintText: hintText,
          tapToUploadLabel: tapToUploadLabel,
          imageFile: field.value ?? initialValue,
          hasError: field.hasError,
          errorText: field.hasError ? field.errorText : null,
          onTap: () async {
            final file = await onPick();
            if (file != null) {
              field.didChange(file);
              onChanged(file);
            }
          },
          onRemove: () {
            field.didChange(null);
            onChanged(null);
          },
        );
      },
    );
  }
}
