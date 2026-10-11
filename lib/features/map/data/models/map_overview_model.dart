class MapOverviewModel {
  const MapOverviewModel({
    required this.empty,
    required this.centerLat,
    required this.centerLng,
    required this.north,
    required this.south,
    required this.east,
    required this.west,
    required this.zoom,
    required this.driverCount,
    required this.organizationCount,
    required this.attorneyCount,
    required this.sosCount,
    required this.totalCount,
  });

  final bool empty;
  final double? centerLat;
  final double? centerLng;
  final double? north;
  final double? south;
  final double? east;
  final double? west;
  final double? zoom;
  final int driverCount;
  final int organizationCount;
  final int attorneyCount;
  final int sosCount;
  final int totalCount;

  bool get hasBounds =>
      !empty &&
      north != null &&
      south != null &&
      east != null &&
      west != null;

  factory MapOverviewModel.empty() => const MapOverviewModel(
        empty: true,
        centerLat: null,
        centerLng: null,
        north: null,
        south: null,
        east: null,
        west: null,
        zoom: null,
        driverCount: 0,
        organizationCount: 0,
        attorneyCount: 0,
        sosCount: 0,
        totalCount: 0,
      );

  factory MapOverviewModel.fromJson(Map<String, dynamic> json) {
    final center = json['center'];
    final bounds = json['bounds'];
    final counts = json['counts'];

    double? centerLat;
    double? centerLng;
    if (center is Map) {
      centerLat = _toDouble(center['lat']);
      centerLng = _toDouble(center['lng'] ?? center['lon']);
    }

    double? north;
    double? south;
    double? east;
    double? west;
    if (bounds is Map) {
      north = _toDouble(bounds['north']);
      south = _toDouble(bounds['south']);
      east = _toDouble(bounds['east']);
      west = _toDouble(bounds['west']);
    }

    int drivers = 0;
    int organizations = 0;
    int attorneys = 0;
    int sos = 0;
    int total = 0;
    if (counts is Map) {
      drivers = _toInt(counts['drivers']);
      organizations = _toInt(counts['organizations']);
      attorneys = _toInt(counts['attorneys']);
      sos = _toInt(counts['sos']);
      total = _toInt(counts['total']);
    }

    final empty = json['empty'] == true ||
        (north == null && south == null && centerLat == null);

    return MapOverviewModel(
      empty: empty,
      centerLat: centerLat,
      centerLng: centerLng,
      north: north,
      south: south,
      east: east,
      west: west,
      zoom: _toDouble(json['zoom']),
      driverCount: drivers,
      organizationCount: organizations,
      attorneyCount: attorneys,
      sosCount: sos,
      totalCount: total,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
