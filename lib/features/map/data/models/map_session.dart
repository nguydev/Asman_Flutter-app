import 'dart:convert';

/// Platform JWT role + map visibility derived from backend ACL.
class MapSession {
  const MapSession({
    required this.userId,
    required this.platformRole,
    required this.organizationIds,
    required this.isDriver,
    required this.driverId,
    required this.subscribeScope,
    required this.canReceiveSos,
    this.displayName,
    this.hubLat,
    this.hubLng,
  });

  final String? userId;
  final String platformRole; // ADMIN | USER | ...
  final List<String> organizationIds;
  final bool isDriver;
  final String? driverId;
  final String subscribeScope; // admin | organizations | none
  final bool canReceiveSos;
  final String? displayName;
  final double? hubLat;
  final double? hubLng;

  bool get isAdmin => platformRole.toUpperCase() == 'ADMIN';
  bool get hasFleetAccess => isAdmin || organizationIds.isNotEmpty;
  bool get hasEmptyVisibility => !isAdmin && organizationIds.isEmpty;

  String get emptyStateMessage {
    if (hasEmptyVisibility) {
      return 'No fleet access yet. Ask an organization owner to add you.';
    }
    return 'No units in this area. Try panning or zooming out.';
  }

  MapSession copyWith({
    String? userId,
    String? platformRole,
    List<String>? organizationIds,
    bool? isDriver,
    String? driverId,
    String? subscribeScope,
    bool? canReceiveSos,
    String? displayName,
    double? hubLat,
    double? hubLng,
  }) {
    return MapSession(
      userId: userId ?? this.userId,
      platformRole: platformRole ?? this.platformRole,
      organizationIds: organizationIds ?? this.organizationIds,
      isDriver: isDriver ?? this.isDriver,
      driverId: driverId ?? this.driverId,
      subscribeScope: subscribeScope ?? this.subscribeScope,
      canReceiveSos: canReceiveSos ?? this.canReceiveSos,
      displayName: displayName ?? this.displayName,
      hubLat: hubLat ?? this.hubLat,
      hubLng: hubLng ?? this.hubLng,
    );
  }

  static MapSession guest() => const MapSession(
        userId: null,
        platformRole: 'USER',
        organizationIds: [],
        isDriver: false,
        driverId: null,
        subscribeScope: 'none',
        canReceiveSos: false,
      );

  /// Seeded NYC hub from backend `location.seed.ts`.
  static const double seedHubLat = 40.7128;
  static const double seedHubLng = -74.006;
  static const double seedHubZoom = 12.0;
}

class JwtPayloadHelper {
  JwtPayloadHelper._();

  static Map<String, dynamic>? decode(String? token) {
    if (token == null || token.isEmpty) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);
    } catch (_) {
      return null;
    }
  }

  static String? role(String? token) {
    final payload = decode(token);
    return payload?['role']?.toString();
  }

  static String? subject(String? token) {
    final payload = decode(token);
    return payload?['sub']?.toString();
  }
}
