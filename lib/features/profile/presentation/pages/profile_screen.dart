import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/data/models/driver_model.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/auth_back_button.dart';
import '../../../auth/presentation/widgets/auth_image_upload_box.dart';
import '../../../auth/presentation/widgets/auth_primary_button.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/document_upload_tile.dart';
import '../../../auth/presentation/widgets/phone_number_field.dart';
import '../../../auth/presentation/widgets/vehicle_type_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _picker = ImagePicker();

  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _nationalIdController;

  String? _vehicleType;
  String? _profileImageUrl;
  String? _driverLicenseUrl;
  String? _vehicleLicenseUrl;
  String? _nationalIdImageUrl;
  String? _vehicleFrontUrl;

  File? _profileImage;
  File? _driverLicenseImage;
  File? _vehicleRegistrationImage;
  File? _nationalIdImage;
  File? _vehicleFrontImage;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _nationalIdController = TextEditingController();

    _initDriverData();
  }

  void _populateDriver(DriverModel driver) {
    _usernameController.text = driver.name;
    _phoneController.text = _cleanPhone(driver.phone);
    _emailController.text = driver.email ?? '';
    _nationalIdController.text = driver.nationalId ?? '';
    _vehicleType = _mapVehicleType(driver.vehicleType);
    _profileImageUrl = driver.image;
    _driverLicenseUrl =
        driver.profiles?['driving_license'] ?? driver.profiles?.drivingLicense;
    _vehicleLicenseUrl =
        driver.profiles?['vehicle_license'] ?? driver.profiles?.vehicleLicense;
    _nationalIdImageUrl =
        driver.profiles?['national_id'] ?? driver.profiles?.nationalId;
    _vehicleFrontUrl =
        driver.profiles?['vehicle_front'] ?? driver.profiles?.vehicleFront;
  }

  Future<void> _initDriverData() async {
    final authCubit = context.read<AuthCubit>();
    final driver = authCubit.currentDriver;
    if (driver != null) {
      setState(() => _populateDriver(driver));
    } else {
      final localDs = di.sl<AuthLocalDataSource>();
      final cached = await localDs.getDriver();
      if (cached != null && mounted) {
        setState(() => _populateDriver(cached));
      }
      authCubit.loadDriverProfile();
    }
  }

  String _cleanPhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('20')) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return digits;
  }

  String? _mapVehicleType(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    final lower = val.toLowerCase();
    if (lower == 'motorcycle' ||
        lower.contains('بخار') ||
        lower.contains('نار')) {
      return 'motorcycle';
    }
    if (lower == 'regular_bike' ||
        lower == 'bicycle' ||
        lower.contains('هوائ') ||
        lower.contains('عجل')) {
      return 'regular_bike';
    }
    return val;
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

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground(context),
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 16.0,
        title: Row(
          children: [
            const AuthBackButton(),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _isEditing ? l10n.profileEditPersonalData : l10n.profilePersonalData,
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
      body: BlocListener<AuthCubit, AuthState>(
        listenWhen: (prev, curr) => curr is AuthAuthenticated,
        listener: (context, state) {
          if (state is AuthAuthenticated &&
              state.driver != null &&
              !_isEditing) {
            setState(() => _populateDriver(state.driver!));
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 24,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Image Area
                    Center(
                      child: Column(
                        children: [
                          Text(
                            l10n.profileProfileImage,
                            style: AppTextStyles.inputText(context),
                          ),
                          const SizedBox(height: 8),
                          AuthImageUploadBox(
                            imageFile: _profileImage,
                            imageUrl: _profileImageUrl,
                            imageAsset: AppAssets.profilePlaceholder,
                            readOnly: !_isEditing,
                            showUploadIcon: _isEditing,
                            onTap: () async {
                              final picked = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (picked != null) {
                                setState(
                                  () => _profileImage = File(picked.path),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Form Fields
                    AuthTextField(
                      controller: _usernameController,
                      label: l10n.profileUserName,
                      hintText: l10n.profileUserName,
                      readOnly: !_isEditing,
                    ),
                    const SizedBox(height: 16),

                    // Phone Number (Always readOnly)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: _isEditing
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: PhoneNumberField(
                                controller: _phoneController,
                                label: l10n.profilePhone,
                                hintText: l10n.profilePhone,
                                readOnly: true,
                              ),
                            ),
                    ),

                    AuthTextField(
                      controller: _emailController,
                      label: l10n.profileEmail,
                      hintText: l10n.profileEmail,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: !_isEditing,
                    ),
                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _nationalIdController,
                      label: l10n.profileNationalId,
                      hintText: l10n.profileNationalId,
                      keyboardType: TextInputType.number,
                      readOnly: !_isEditing,
                    ),
                    const SizedBox(height: 16),

                    VehicleTypeField(
                      label: l10n.profileVehicleType,
                      hintText: l10n.profileVehicleType,
                      items: {
                        'motorcycle',
                        'regular_bike',
                        if (_vehicleType != null && _vehicleType!.isNotEmpty)
                          _vehicleType!,
                      }.toList(),
                      initialValue: _vehicleType,
                      readOnly: !_isEditing,
                      itemLabelBuilder: (val) => _vehicleLabel(l10n, val),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (v) => null,
                      onChanged: (val) {
                        setState(() => _vehicleType = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Documents
                    DocumentUploadTile(
                      label: l10n.profileDriverLicense,
                      hintText: l10n.profileDriverLicense,
                      tapToUploadLabel: l10n.profileUploadPrompt,
                      imageFile: _driverLicenseImage,
                      imageUrl: _driverLicenseUrl,
                      readOnly: !_isEditing,
                      onTap: () async {
                        final picked = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked != null) {
                          setState(
                            () => _driverLicenseImage = File(picked.path),
                          );
                        }
                      },
                      onRemove: () {
                        setState(() {
                          _driverLicenseImage = null;
                          _driverLicenseUrl = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    DocumentUploadTile(
                      label: l10n.profileVehicleRegistration,
                      hintText: l10n.profileVehicleRegistration,
                      tapToUploadLabel: l10n.profileUploadPrompt,
                      imageFile: _vehicleRegistrationImage,
                      imageUrl: _vehicleLicenseUrl,
                      readOnly: !_isEditing,
                      onTap: () async {
                        final picked = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked != null) {
                          setState(
                            () =>
                                _vehicleRegistrationImage = File(picked.path),
                          );
                        }
                      },
                      onRemove: () {
                        setState(() {
                          _vehicleRegistrationImage = null;
                          _vehicleLicenseUrl = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    DocumentUploadTile(
                      label: l10n.profileNationalIdImage,
                      hintText: l10n.profileNationalIdImage,
                      tapToUploadLabel: l10n.profileUploadPrompt,
                      imageFile: _nationalIdImage,
                      imageUrl: _nationalIdImageUrl,
                      readOnly: !_isEditing,
                      onTap: () async {
                        final picked = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked != null) {
                          setState(
                            () => _nationalIdImage = File(picked.path),
                          );
                        }
                      },
                      onRemove: () {
                        setState(() {
                          _nationalIdImage = null;
                          _nationalIdImageUrl = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    DocumentUploadTile(
                      label: l10n.profileVehicleFront,
                      hintText: l10n.profileVehicleFront,
                      tapToUploadLabel: l10n.profileUploadPrompt,
                      imageFile: _vehicleFrontImage,
                      imageUrl: _vehicleFrontUrl,
                      readOnly: !_isEditing,
                      onTap: () async {
                        final picked = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked != null) {
                          setState(
                            () => _vehicleFrontImage = File(picked.path),
                          );
                        }
                      },
                      onRemove: () {
                        setState(() {
                          _vehicleFrontImage = null;
                          _vehicleFrontUrl = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Pinned Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground(context),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: AuthPrimaryButton(
                  label: _isEditing ? l10n.confirm : l10n.profileRequestEdit,
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
