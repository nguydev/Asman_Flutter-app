class MapMarkerModel {
  final String id;
  final String role; // DRIVER, ORGANIZATION, ATTORNEY, SOS
  final bool live;
  final double lat;
  final double lng;
  final String? name;
  final String? avatar;

  // Driver specific fields
  final String? driverId;
  final String? userId;
  final String? unitNumber;
  final double? speed;
  final double? heading;
  final DateTime? deviceTs;
  final DateTime? receivedTs;

  // Address specific fields
  final String? city;
  final String? state;

  // SOS specific fields
  final String? status;
  final String? detail;
  final DateTime? createdAt;

  MapMarkerModel({
    required this.id,
    required this.role,
    required this.live,
    required this.lat,
    required this.lng,
    this.name,
    this.avatar,
    this.driverId,
    this.userId,
    this.unitNumber,
    this.speed,
    this.heading,
    this.deviceTs,
    this.receivedTs,
    this.city,
    this.state,
    this.status,
    this.detail,
    this.createdAt,
  });

  factory MapMarkerModel.fromJson(Map<String, dynamic> json) {
    final role = (json['role'] ?? json['type'] ?? 'DRIVER')
        .toString()
        .toUpperCase();
    final driverId = json['driverId']?.toString();
    final id = (json['id'] ?? (role == 'DRIVER' ? driverId : null) ?? '')
        .toString();

    return MapMarkerModel(
      id: id,
      role: role,
      live: json['live'] == true,
      lat: _toDouble(json['lat']) ?? 0,
      lng: _toDouble(json['lng'] ?? json['lon']) ?? 0,
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      driverId: driverId,
      userId: json['userId']?.toString(),
      unitNumber: json['unitNumber']?.toString(),
      speed: _toDouble(json['speed']),
      heading: _toDouble(json['heading']),
      deviceTs: json['deviceTs'] != null
          ? DateTime.tryParse(json['deviceTs'].toString())
          : null,
      receivedTs: json['receivedTs'] != null
          ? DateTime.tryParse(json['receivedTs'].toString())
          : null,
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      status: json['status']?.toString(),
      detail: (json['detail'] ?? json['message'])?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  factory MapMarkerModel.fromSocketUpdate(
    Map<String, dynamic> json,
    MapMarkerModel? existing,
  ) {
    final driverId = (json['driverId'] ?? json['id'] ?? '').toString();

    return MapMarkerModel(
      id: driverId,
      role: 'DRIVER',
      live: true,
      lat: _toDouble(json['lat']) ?? existing?.lat ?? 0,
      lng: _toDouble(json['lon'] ?? json['lng']) ?? existing?.lng ?? 0,
      name: existing?.name ?? 'Driver',
      avatar: existing?.avatar,
      driverId: driverId,
      userId: existing?.userId,
      unitNumber: existing?.unitNumber,
      speed: _toDouble(json['speed']) ?? existing?.speed,
      heading: _toDouble(json['heading']) ?? existing?.heading,
      deviceTs: json['deviceTs'] != null
          ? DateTime.tryParse(json['deviceTs'].toString())
          : existing?.deviceTs,
      receivedTs: json['receivedTs'] != null
          ? DateTime.tryParse(json['receivedTs'].toString())
          : DateTime.now(),
      city: existing?.city,
      state: existing?.state,
    );
  }

  MapMarkerModel copyWith({
    bool? live,
    double? lat,
    double? lng,
    double? speed,
    double? heading,
    DateTime? deviceTs,
    DateTime? receivedTs,
    String? status,
    String? detail,
    DateTime? createdAt,
  }) {
    return MapMarkerModel(
      id: id,
      role: role,
      live: live ?? this.live,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      name: name,
      avatar: avatar,
      driverId: driverId,
      userId: userId,
      unitNumber: unitNumber,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      deviceTs: deviceTs ?? this.deviceTs,
      receivedTs: receivedTs ?? this.receivedTs,
      city: city,
      state: state,
      status: status ?? this.status,
      detail: detail ?? this.detail,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class MapClusterModel {
  final double lat;
  final double lng;
  final int count;
  final int drivers;

  MapClusterModel({
    required this.lat,
    required this.lng,
    required this.count,
    required this.drivers,
  });

  factory MapClusterModel.fromJson(Map<String, dynamic> json) {
    return MapClusterModel(
      lat: MapMarkerModel._toDouble(json['lat']) ?? 0,
      lng: MapMarkerModel._toDouble(json['lng'] ?? json['lon']) ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      drivers: (json['drivers'] as num?)?.toInt() ?? 0,
    );
  }
}
