import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/features/auth/data/models/driver_model.dart';

void main() {
  group('DriverModel & DriverProfilesModel Tests', () {
    test('supports index operator on DriverProfilesModel', () {
      const profiles = DriverProfilesModel(
        drivingLicense: 'https://example.com/dl.jpg',
        vehicleLicense: 'https://example.com/vl.jpg',
        nationalId: 'https://example.com/nid.jpg',
        vehicleFront: 'https://example.com/vf.jpg',
      );

      expect(profiles['driving_license'], 'https://example.com/dl.jpg');
      expect(profiles['vehicle_license'], 'https://example.com/vl.jpg');
      expect(profiles['national_id'], 'https://example.com/nid.jpg');
      expect(profiles['vehicle_front'], 'https://example.com/vf.jpg');
      expect(profiles['unknown'], isNull);
    });

    test('parses nested delivery object from GET /auth/me payload', () {
      final json = {
        'status': 200,
        'msg': 'تم بنجاح',
        'delivery': {
          'id': 5,
          'name': 'Captain Jack',
          'phone': '01012345678',
          'image': 'https://example.com/avatar.jpg',
          'profiles': {
            'driving_license': 'https://example.com/dl.jpg',
            'vehicle_license': 'https://example.com/vl.jpg',
            'national_id': 'https://example.com/nid.jpg',
            'vehicle_front': 'https://example.com/vf.jpg',
          },
        },
      };

      final driver = DriverModel.fromJson(json);

      expect(driver.id, 5);
      expect(driver.name, 'Captain Jack');
      expect(driver.image, 'https://example.com/avatar.jpg');
      expect(driver.profiles?['driving_license'], 'https://example.com/dl.jpg');
      expect(driver.profiles?['vehicle_license'], 'https://example.com/vl.jpg');
      expect(driver.profiles?['national_id'], 'https://example.com/nid.jpg');
      expect(driver.profiles?['vehicle_front'], 'https://example.com/vf.jpg');
    });

    test('parses flat driver model and dynamic profiles map', () {
      final json = {
        'id': 10,
        'name': 'Driver Smith',
        'phone': '01122334455',
        'profiles': <dynamic, dynamic>{
          'drivingLicense': 'https://example.com/dl2.jpg',
          'vehicleLicense': 'https://example.com/vl2.jpg',
          'nationalId': 'https://example.com/nid2.jpg',
          'vehicleFront': 'https://example.com/vf2.jpg',
        },
      };

      final driver = DriverModel.fromJson(json);

      expect(driver.id, 10);
      expect(driver.profiles?['driving_license'], 'https://example.com/dl2.jpg');
      expect(driver.profiles?['vehicle_license'], 'https://example.com/vl2.jpg');
      expect(driver.profiles?['national_id'], 'https://example.com/nid2.jpg');
      expect(driver.profiles?['vehicle_front'], 'https://example.com/vf2.jpg');
    });
  });
}
