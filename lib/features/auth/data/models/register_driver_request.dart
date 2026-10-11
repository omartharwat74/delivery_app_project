import 'dart:io';
import 'package:dio/dio.dart';

class RegisterDriverRequest {
  final String registrationToken;
  final String name;
  final String phone;
  final String? email;
  final String? nationalId;
  final String vehicleType;
  final String areaId;
  final String shiftId;
  final File image;
  final File drivingLicense;
  final File vehicleLicense;
  final File nationalIdImage;
  final File vehicleFront;

  const RegisterDriverRequest({
    required this.registrationToken,
    required this.name,
    required this.phone,
    this.email,
    this.nationalId,
    required this.vehicleType,
    required this.areaId,
    required this.shiftId,
    required this.image,
    required this.drivingLicense,
    required this.vehicleLicense,
    required this.nationalIdImage,
    required this.vehicleFront,
  });

  /// Converts fields and image files to FormData for multipart/form-data upload.
  /// Dio will automatically set the multipart boundary and Content-Type.
  Future<FormData> toFormData() async {
    final Map<String, dynamic> map = {
      'registration_token': registrationToken,
      'name': name,
      'phone': phone,
      'vehicle_type': vehicleType,
      'area_id': areaId,
      'shift_id': shiftId,
    };

    if (email != null && email!.isNotEmpty) {
      map['email'] = email;
    }
    if (nationalId != null && nationalId!.isNotEmpty) {
      map['national_id'] = nationalId;
    }

    map['image'] = await MultipartFile.fromFile(
      image.path,
      filename: image.path.split('/').last,
    );
    map['driving_license'] = await MultipartFile.fromFile(
      drivingLicense.path,
      filename: drivingLicense.path.split('/').last,
    );
    map['vehicle_license'] = await MultipartFile.fromFile(
      vehicleLicense.path,
      filename: vehicleLicense.path.split('/').last,
    );
    map['national_id_image'] = await MultipartFile.fromFile(
      nationalIdImage.path,
      filename: nationalIdImage.path.split('/').last,
    );
    map['vehicle_front'] = await MultipartFile.fromFile(
      vehicleFront.path,
      filename: vehicleFront.path.split('/').last,
    );

    return FormData.fromMap(map);
  }
}
