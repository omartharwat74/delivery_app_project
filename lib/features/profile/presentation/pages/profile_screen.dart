import 'dart:io';
import 'package:delivery_app_project/core/constants/app_assets.dart';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
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

  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _nationalIdController;

  String? _vehicleType = 'دراجه بخارية';

  File? _profileImage;
  File? _driverLicenseImage;
  File? _vehicleRegistrationImage;
  File? _nationalIdImage;

  @override
  void initState() {
    super.initState();
    // Pre-fill with mock data for visual testing
    _usernameController = TextEditingController(text: 'خالد على');
    _phoneController = TextEditingController(
      text: '1004059966',
    ); // Phone without prefix
    _emailController = TextEditingController(text: 'afarag870@gmail.com');
    _nationalIdController = TextEditingController(text: '123040533234');

    // Using dummy files for mock rendering of images
    _profileImage = null; // File('mock_profile_image.png');
    _driverLicenseImage = null; // File('mock_license.png');
    _vehicleRegistrationImage = null; // File('mock_vehicle.png');
    _nationalIdImage = null; // File('mock_national_id.png');
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
      body: Column(
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
                          imageAsset: AppAssets.profileAvatar,
                          readOnly: !_isEditing,
                          showUploadIcon: _isEditing,
                          onTap: () {},
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

                  // Phone Number (Only in View Mode)
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
                    items: const ['سيارة', 'دراجه بخارية', 'عجلة'],
                    initialValue: _vehicleType,
                    readOnly: !_isEditing,
                    itemLabelBuilder: (val) => val,
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
                    readOnly: !_isEditing,
                    onTap: () {},
                    onRemove: () {
                      setState(() => _driverLicenseImage = null);
                    },
                  ),
                  const SizedBox(height: 16),

                  DocumentUploadTile(
                    label: l10n.profileVehicleRegistration,
                    hintText: l10n.profileVehicleRegistration,
                    tapToUploadLabel: l10n.profileUploadPrompt,
                    imageFile: _vehicleRegistrationImage,
                    readOnly: !_isEditing,
                    onTap: () {},
                    onRemove: () {
                      setState(() => _vehicleRegistrationImage = null);
                    },
                  ),
                  const SizedBox(height: 16),

                  DocumentUploadTile(
                    label: l10n.profileNationalIdImage,
                    hintText: l10n.profileNationalIdImage,
                    tapToUploadLabel: l10n.profileUploadPrompt,
                    imageFile: _nationalIdImage,
                    readOnly: !_isEditing,
                    onTap: () {},
                    onRemove: () {
                      setState(() => _nationalIdImage = null);
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
    );
  }
}
