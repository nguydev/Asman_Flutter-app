class DriverProfileResponse {
  final bool? success;
  final String? message;
  final int? statusCode;
  final DriverProfileData? data;

  DriverProfileResponse({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory DriverProfileResponse.fromJson(Map<String, dynamic> json) {
    return DriverProfileResponse(
      success: json['success'] is bool
          ? json['success'] as bool?
          : (json['success']?.toString() == 'true' || json['success'] == 1),
      message: json['message']?.toString(),
      statusCode: json['statusCode'] is int
          ? json['statusCode'] as int?
          : int.tryParse(json['statusCode']?.toString() ?? ''),
      data: json['data'] != null ? DriverProfileData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'statusCode': statusCode,
      'data': data?.toJson(),
    };
  }
}

class DriverProfileData {
  final String? id;
  final String? email;
  final String? phone;
  final String? role;
  final bool? isEmailVerified;
  final bool? isPhoneVerified;
  final String? createdAt;
  final String? updatedAt;
  final DriverInfo? driver;
  final DriverProfileInfo? profile;

  DriverProfileData({
    this.id,
    this.email,
    this.phone,
    this.role,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.createdAt,
    this.updatedAt,
    this.driver,
    this.profile,
  });

  factory DriverProfileData.fromJson(Map<String, dynamic> json) {
    return DriverProfileData(
      id: json['id']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      role: json['role']?.toString(),
      isEmailVerified: json['isEmailVerified'] is bool
          ? json['isEmailVerified'] as bool?
          : (json['isEmailVerified']?.toString() == 'true' || json['isEmailVerified'] == 1),
      isPhoneVerified: json['isPhoneVerified'] is bool
          ? json['isPhoneVerified'] as bool?
          : (json['isPhoneVerified']?.toString() == 'true' || json['isPhoneVerified'] == 1),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      driver: json['driver'] != null ? DriverInfo.fromJson(json['driver']) : null,
      profile: json['profile'] != null ? DriverProfileInfo.fromJson(json['profile']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'role': role,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'driver': driver?.toJson(),
      'profile': profile?.toJson(),
    };
  }
}

class DriverInfo {
  final String? id;
  final String? vinNumber;
  final String? licensePlate;

  DriverInfo({
    this.id,
    this.vinNumber,
    this.licensePlate,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id']?.toString(),
      vinNumber: json['vinNumber']?.toString(),
      licensePlate: json['licensePlate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vinNumber': vinNumber,
      'licensePlate': licensePlate,
    };
  }
}

class DriverProfileInfo {
  final String? name;
  final String? avatarUrl;
  final String? address;

  DriverProfileInfo({
    this.name,
    this.avatarUrl,
    this.address,
  });

  factory DriverProfileInfo.fromJson(Map<String, dynamic> json) {
    String? addressStr;
    if (json['address'] != null) {
      if (json['address'] is Map) {
        final addrMap = json['address'] as Map;
        addressStr = addrMap['street']?.toString() ?? addrMap['address']?.toString();
      } else {
        addressStr = json['address']?.toString();
      }
    }
    return DriverProfileInfo(
      name: json['name']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      address: addressStr,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatarUrl': avatarUrl,
      'address': address,
    };
  }
}
