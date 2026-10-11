class DriverModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? nationalId;
  final String? image;
  final String? vehicleType;
  final String status;
  final bool isOnline;
  final bool isBusy;
  final bool canAcceptOrders;
  final double? currentLat;
  final double? currentLng;
  final double? ratingAvg;
  final int? ratingCount;
  final DriverAreaModel? area;
  final DriverShiftModel? shift;
  final DriverProfilesModel? profiles;

  const DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.nationalId,
    this.image,
    this.vehicleType,
    this.status = 'active',
    this.isOnline = false,
    this.isBusy = false,
    this.canAcceptOrders = false,
    this.currentLat,
    this.currentLng,
    this.ratingAvg,
    this.ratingCount,
    this.area,
    this.shift,
    this.profiles,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    final effectiveJson = json['delivery'] is Map<String, dynamic>
        ? json['delivery'] as Map<String, dynamic>
        : (json['driver'] is Map<String, dynamic>
            ? json['driver'] as Map<String, dynamic>
            : json);

    return DriverModel(
      id: effectiveJson['id'] as int? ?? 0,
      name: effectiveJson['name'] as String? ?? '',
      phone: effectiveJson['phone'] as String? ?? '',
      email: effectiveJson['email'] as String?,
      nationalId: effectiveJson['national_id'] as String?,
      image: effectiveJson['image'] as String?,
      vehicleType: effectiveJson['vehicle_type'] as String?,
      status: effectiveJson['status'] as String? ?? 'active',
      isOnline: effectiveJson['is_online'] as bool? ?? false,
      isBusy: effectiveJson['is_busy'] as bool? ?? false,
      canAcceptOrders: effectiveJson['can_accept_orders'] as bool? ?? false,
      currentLat: (effectiveJson['current_lat'] as num?)?.toDouble(),
      currentLng: (effectiveJson['current_lng'] as num?)?.toDouble(),
      ratingAvg: (effectiveJson['rating_avg'] as num?)?.toDouble(),
      ratingCount: effectiveJson['rating_count'] as int?,
      area: effectiveJson['area'] != null && effectiveJson['area'] is Map<String, dynamic>
          ? DriverAreaModel.fromJson(effectiveJson['area'] as Map<String, dynamic>)
          : null,
      shift: effectiveJson['shift'] != null && effectiveJson['shift'] is Map<String, dynamic>
          ? DriverShiftModel.fromJson(effectiveJson['shift'] as Map<String, dynamic>)
          : null,
      profiles: effectiveJson['profiles'] != null && effectiveJson['profiles'] is Map
          ? DriverProfilesModel.fromJson(effectiveJson['profiles'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'national_id': nationalId,
      'image': image,
      'vehicle_type': vehicleType,
      'status': status,
      'is_online': isOnline,
      'is_busy': isBusy,
      'can_accept_orders': canAcceptOrders,
      'current_lat': currentLat,
      'current_lng': currentLng,
      'rating_avg': ratingAvg,
      'rating_count': ratingCount,
      'area': area?.toJson(),
      'shift': shift?.toJson(),
      'profiles': profiles?.toJson(),
    };
  }
}

class DriverAreaModel {
  final int id;
  final String name;

  const DriverAreaModel({required this.id, required this.name});

  factory DriverAreaModel.fromJson(Map<String, dynamic> json) {
    return DriverAreaModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class DriverShiftModel {
  final int id;
  final String name;
  final String? startsAt;
  final String? endsAt;

  const DriverShiftModel({
    required this.id,
    required this.name,
    this.startsAt,
    this.endsAt,
  });

  factory DriverShiftModel.fromJson(Map<String, dynamic> json) {
    return DriverShiftModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      startsAt: json['starts_at'] as String?,
      endsAt: json['ends_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'starts_at': startsAt,
        'ends_at': endsAt,
      };
}

class DriverProfilesModel {
  final String? drivingLicense;
  final String? vehicleLicense;
  final String? nationalId;
  final String? vehicleFront;

  const DriverProfilesModel({
    this.drivingLicense,
    this.vehicleLicense,
    this.nationalId,
    this.vehicleFront,
  });

  String? operator [](String key) {
    switch (key) {
      case 'driving_license':
      case 'drivingLicense':
        return drivingLicense;
      case 'vehicle_license':
      case 'vehicleLicense':
        return vehicleLicense;
      case 'national_id':
      case 'nationalId':
        return nationalId;
      case 'vehicle_front':
      case 'vehicleFront':
        return vehicleFront;
      default:
        return null;
    }
  }

  factory DriverProfilesModel.fromJson(Map<dynamic, dynamic> json) {
    return DriverProfilesModel(
      drivingLicense:
          (json['driving_license'] ?? json['drivingLicense']) as String?,
      vehicleLicense:
          (json['vehicle_license'] ?? json['vehicleLicense']) as String?,
      nationalId: (json['national_id'] ?? json['nationalId']) as String?,
      vehicleFront: (json['vehicle_front'] ?? json['vehicleFront']) as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'driving_license': drivingLicense,
        'vehicle_license': vehicleLicense,
        'national_id': nationalId,
        'vehicle_front': vehicleFront,
      };
}
