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
    return DriverModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      nationalId: json['national_id'] as String?,
      image: json['image'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      status: json['status'] as String? ?? 'active',
      isOnline: json['is_online'] as bool? ?? false,
      isBusy: json['is_busy'] as bool? ?? false,
      canAcceptOrders: json['can_accept_orders'] as bool? ?? false,
      currentLat: (json['current_lat'] as num?)?.toDouble(),
      currentLng: (json['current_lng'] as num?)?.toDouble(),
      ratingAvg: (json['rating_avg'] as num?)?.toDouble(),
      ratingCount: json['rating_count'] as int?,
      area: json['area'] != null && json['area'] is Map<String, dynamic>
          ? DriverAreaModel.fromJson(json['area'] as Map<String, dynamic>)
          : null,
      shift: json['shift'] != null && json['shift'] is Map<String, dynamic>
          ? DriverShiftModel.fromJson(json['shift'] as Map<String, dynamic>)
          : null,
      profiles: json['profiles'] != null && json['profiles'] is Map<String, dynamic>
          ? DriverProfilesModel.fromJson(json['profiles'] as Map<String, dynamic>)
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

  factory DriverProfilesModel.fromJson(Map<String, dynamic> json) {
    return DriverProfilesModel(
      drivingLicense: json['driving_license'] as String?,
      vehicleLicense: json['vehicle_license'] as String?,
      nationalId: json['national_id'] as String?,
      vehicleFront: json['vehicle_front'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'driving_license': drivingLicense,
        'vehicle_license': vehicleLicense,
        'national_id': nationalId,
        'vehicle_front': vehicleFront,
      };
}
