import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/constants/app_constants.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/core/services/cache_service.dart';
import 'package:flutter_task/core/services/location_socket_service.dart';
import 'package:flutter_task/features/map/data/models/map_marker_model.dart';
import 'package:flutter_task/features/map/data/models/map_overview_model.dart';
import 'package:flutter_task/features/map/data/models/map_session.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Fleet map controller — REST viewport + socket live merge + role personalization.
///
/// Contracts: backend `specs/17-flutter-map-integration.md` + `MapVisibilityService`.
class MapFeatureController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final CacheService _cacheService = Get.find<CacheService>();
  final LocationSocketService _socketService = LocationSocketService();

  final isLoading = false.obs;
  final liveUpdatesUnavailable = false.obs;
  final sessionLoading = true.obs;
  final overviewLoading = false.obs;
  final markersMap = <String, MapMarkerModel>{}.obs;
  final clustersList = <MapClusterModel>[].obs;
  final session = MapSession.guest().obs;
  final markerCount = 0.obs;
  final overview = MapOverviewModel.empty().obs;
  final socketFocusRevision = 0.obs;

  /// Suggested camera target from overview (or org fallback).
  final preferredCenter = Rxn<LatLng>();
  final preferredZoom = 12.0.obs;
  final preferredBounds = Rxn<LatLngBounds>();

  StreamSubscription? _locationSub;
  StreamSubscription? _sosSub;
  StreamSubscription? _mapFocusSub;
  StreamSubscription? _connectedSub;
  Timer? _cameraDebounceTimer;
  Timer? _staleCheckTimer;
  bool _retriedEmptyViewport = false;
  LatLngBounds? _lastBounds;
  double? _lastZoom;
  final Map<String, MapMarkerModel> _socketDriverMarkers = {};

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    sessionLoading.value = true;
    await _resolveSession();
    await fetchOverview();
    _initSocketAndListeners();
    _startStaleCheckTimer();
    sessionLoading.value = false;
  }

  Future<void> refreshSession() async {
    await _resolveSession();
    await fetchOverview();
    if (_socketService.isConnected.value) {
      await _subscribeForCurrentSession();
    } else {
      _socketService.connect();
    }
  }

  Future<void> _resolveSession() async {
    final token = _cacheService.get<String>(AppConstants.accessToken);
    final jwtRole = JwtPayloadHelper.role(token) ?? 'USER';
    final userId = JwtPayloadHelper.subject(token);
    await _cacheService.put(AppConstants.cacheUserRole, jwtRole);

    String? displayName;
    String? driverId;
    var isDriver = false;
    double? hubLat;
    double? hubLng;
    final orgIds = <String>[];

    // Profile: driver record + display name
    try {
      final profileRes = await _apiService.get(ApiConstants.getProfile);
      final root = profileRes.data;
      final data = root is Map && root['data'] is Map
          ? Map<String, dynamic>.from(root['data'] as Map)
          : (root is Map ? Map<String, dynamic>.from(root) : null);
      if (data != null) {
        displayName = (data['profile'] is Map)
            ? (data['profile']['name']?.toString())
            : data['name']?.toString();
        if (data['driver'] is Map) {
          isDriver = true;
          driverId = data['driver']['id']?.toString();
        }
        final roleFromProfile = data['role']?.toString();
        if (roleFromProfile != null && roleFromProfile.isNotEmpty) {
          await _cacheService.put(AppConstants.cacheUserRole, roleFromProfile);
        }
      }
    } catch (e) {
      debugPrint('⚠️ [Map] profile fetch failed: $e');
    }

    // Organizations the user can see (membership-scoped, or all for ADMIN)
    try {
      final orgRes = await _apiService.get(
        ApiConstants.organizations,
        queryParameters: {'limit': 50},
      );
      final orgs = _extractList(orgRes.data);
      for (final raw in orgs) {
        if (raw is! Map) continue;
        final org = Map<String, dynamic>.from(raw);
        final id = org['id']?.toString();
        if (id == null || id.isEmpty) continue;
        orgIds.add(id);

        final address = org['address'];
        if (hubLat == null && address is Map) {
          final lat = double.tryParse(address['latitude']?.toString() ?? '');
          final lng = double.tryParse(address['longitude']?.toString() ?? '');
          if (lat != null && lng != null) {
            hubLat = lat;
            hubLng = lng;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [Map] organizations fetch failed: $e');
    }

    final platformRole =
        (_cacheService.get<String>(AppConstants.cacheUserRole) ?? jwtRole)
            .toUpperCase();
    final isAdmin = platformRole == 'ADMIN';

    // Managers (no driver socket identity) can join SOS rooms via dashboard.
    final canReceiveSos = isAdmin || (!isDriver && orgIds.isNotEmpty);

    session.value = MapSession(
      userId: userId,
      platformRole: platformRole,
      organizationIds: orgIds,
      isDriver: isDriver,
      driverId: driverId,
      subscribeScope: isAdmin
          ? 'admin'
          : (orgIds.isEmpty ? 'none' : 'organizations'),
      canReceiveSos: canReceiveSos,
      displayName: displayName,
      hubLat: hubLat,
      hubLng: hubLng,
    );

    // Soft fallback until /map/overview responds (org address only).
    if (hubLat != null && hubLng != null) {
      preferredCenter.value = LatLng(hubLat, hubLng);
      preferredZoom.value = MapSession.seedHubZoom;
    } else {
      preferredCenter.value = null;
      preferredBounds.value = null;
    }

    debugPrint(
      '📍 [Map] session role=$platformRole orgs=${orgIds.length} '
      'driver=$isDriver sos=$canReceiveSos hub=($hubLat,$hubLng)',
    );
  }

  /// Visibility-scoped fit-bounds from `GET /api/v1/map/overview`.
  Future<MapOverviewModel> fetchOverview() async {
    overviewLoading.value = true;
    try {
      final response = await _apiService.get(ApiConstants.mapOverview);
      final root = response.data;
      Map<String, dynamic>? payload;
      if (root is Map) {
        final data = root['data'];
        if (data is Map &&
            (data.containsKey('bounds') || data.containsKey('empty'))) {
          payload = Map<String, dynamic>.from(data);
        } else if (root.containsKey('empty') || root.containsKey('bounds')) {
          payload = Map<String, dynamic>.from(root);
        }
      }

      final model = payload != null
          ? MapOverviewModel.fromJson(payload)
          : MapOverviewModel.empty();
      overview.value = model;
      _applyOverviewCamera(model);
      // Notify map screen to re-frame (same path as socket map:focus).
      socketFocusRevision.value++;
      debugPrint(
        '📍 [Map] overview empty=${model.empty} total=${model.totalCount} '
        'zoom=${model.zoom} bounds=(${model.south},${model.west})-(${model.north},${model.east})',
      );
      return model;
    } catch (e) {
      debugPrint('⚠️ [Map] overview fetch failed: $e');
      overview.value = MapOverviewModel.empty();
      return overview.value;
    } finally {
      overviewLoading.value = false;
    }
  }

  Future<bool> focusOrganization(String organizationId) async {
    try {
      overviewLoading.value = true;
      final response = await _apiService.get(
        ApiConstants.mapOrganizationFocus(organizationId),
      );
      final root = response.data;
      Map<String, dynamic>? payload;
      if (root is Map) {
        final data = root['data'];
        if (data is Map) {
          payload = Map<String, dynamic>.from(data);
        } else {
          payload = Map<String, dynamic>.from(root);
        }
      }
      if (payload == null) return false;
      _applyFocusPayload(payload);
      return true;
    } catch (e) {
      debugPrint('❌ [Map] organization focus failed: $e');
      return false;
    } finally {
      overviewLoading.value = false;
    }
  }

  void _applyFocusPayload(Map<String, dynamic> focus) {
    final model = MapOverviewModel.fromJson(focus);
    if (model.empty) return;

    overview.value = model;
    _applyOverviewCamera(model);
    socketFocusRevision.value++;
  }

  void _applyOverviewCamera(MapOverviewModel model) {
    final hubLat = session.value.hubLat;
    final hubLng = session.value.hubLng;

    // Org viewers: if overview spans continents (e.g. one live driver in
    // Dhaka + fleet in NYC), frame the organization hub — not the world.
    if (!session.value.isAdmin && _isOverviewSpanTooLarge(model)) {
      final lat = hubLat ??
          (session.value.hasFleetAccess ? MapSession.seedHubLat : null);
      final lng = hubLng ??
          (session.value.hasFleetAccess ? MapSession.seedHubLng : null);
      if (lat != null && lng != null) {
        preferredCenter.value = LatLng(lat, lng);
        preferredZoom.value = MapSession.seedHubZoom;
        preferredBounds.value = null;
        debugPrint(
          '📍 [Map] overview span too large '
          '(zoom=${model.zoom} bounds=(${model.south},${model.west})-'
          '(${model.north},${model.east})); focusing org hub ($lat,$lng)',
        );
        return;
      }
    }

    if (model.hasBounds) {
      preferredBounds.value = LatLngBounds(
        southwest: LatLng(model.south!, model.west!),
        northeast: LatLng(model.north!, model.east!),
      );
      if (model.centerLat != null && model.centerLng != null) {
        preferredCenter.value = LatLng(model.centerLat!, model.centerLng!);
      } else {
        preferredCenter.value = LatLng(
          (model.north! + model.south!) / 2,
          (model.east! + model.west!) / 2,
        );
      }
      preferredZoom.value = model.zoom ?? 12;
      return;
    }

    if (model.centerLat != null && model.centerLng != null) {
      preferredCenter.value = LatLng(model.centerLat!, model.centerLng!);
      preferredZoom.value = model.zoom ?? 14;
      preferredBounds.value = null;
      return;
    }

    // Keep session hub if overview is empty.
    if (hubLat != null && hubLng != null) {
      preferredCenter.value = LatLng(hubLat, hubLng);
      preferredZoom.value = MapSession.seedHubZoom;
    }
  }

  /// True when overview would frame a near-global map (not a local fleet).
  bool _isOverviewSpanTooLarge(MapOverviewModel model) {
    final zoom = model.zoom;
    if (zoom != null && zoom < 9) return true;
    if (!model.hasBounds) return false;
    final latSpan = (model.north! - model.south!).abs();
    final lngSpan = (model.east! - model.west!).abs();
    // ~4° ≈ 450km — larger than a metro fleet area.
    return latSpan > 4 || lngSpan > 4;
  }

  List<dynamic> _extractList(dynamic responseData) {
    if (responseData is List) return responseData;
    if (responseData is! Map) return const [];
    final root = Map<String, dynamic>.from(responseData);
    final data = root['data'];
    if (data is List) return data;
    if (data is Map) {
      final nested = data['data'];
      if (nested is List) return nested;
      if (data['items'] is List) return data['items'] as List;
    }
    if (root['items'] is List) return root['items'] as List;
    return const [];
  }

  void _initSocketAndListeners() {
    _socketService.connect();

    _connectedSub = _socketService.connectedStream.listen((_) async {
      liveUpdatesUnavailable.value = false;
      await _subscribeForCurrentSession();
      final bounds = _lastBounds;
      final zoom = _lastZoom;
      if (bounds != null && zoom != null) {
        fetchViewportMarkers(bounds: bounds, zoom: zoom, debounce: false);
      }
    });

    _locationSub = _socketService.locationUpdateStream.listen((data) {
      final driverId = (data['driverId'] ?? data['id'] ?? '').toString();
      if (driverId.isEmpty) return;

      final existing = markersMap[driverId] ?? _socketDriverMarkers[driverId];
      final nextTsStr = data['deviceTs']?.toString();
      final nextTs = nextTsStr != null ? DateTime.tryParse(nextTsStr) : null;

      if (existing != null && existing.deviceTs != null && nextTs != null) {
        if (nextTs.isBefore(existing.deviceTs!)) return;
      }

      final updatedMarker = MapMarkerModel.fromSocketUpdate(data, existing);
      _socketDriverMarkers[driverId] = updatedMarker;
      if (_isInsideLastBounds(updatedMarker)) {
        markersMap[driverId] = updatedMarker;
      } else {
        markersMap.remove(driverId);
      }
      markerCount.value = markersMap.length;
    });

    _mapFocusSub = _socketService.mapFocusStream.listen((focusData) {
      _applyFocusPayload(focusData);
    });

    _sosSub = _socketService.sosAlertStream.listen((sosData) {
      if (!session.value.canReceiveSos) return;
      debugPrint('🚨 [Map] SOS Alert: $sosData');
      _upsertSosAlert(sosData);
      _showSosAlert(sosData);
    });
  }

  Future<void> _subscribeForCurrentSession() async {
    final s = session.value;
    final ack = await _socketService.subscribeForViewer(
      isAdmin: s.isAdmin,
      isDriverEmitter: s.isDriver,
      organizationIds: s.organizationIds,
    );

    if (ack == null) {
      liveUpdatesUnavailable.value = true;
      return;
    }

    liveUpdatesUnavailable.value = false;
    final scope = ack['scope']?.toString() ?? s.subscribeScope;
    final ids = <String>[];
    if (ack['organizationIds'] is List) {
      for (final id in ack['organizationIds'] as List) {
        final v = id?.toString();
        if (v != null && v.isNotEmpty) ids.add(v);
      }
    }

    session.value = s.copyWith(
      subscribeScope: scope,
      organizationIds: ids.isNotEmpty ? ids : s.organizationIds,
    );
    final focus = ack['focus'];
    if (focus is Map) {
      _applyFocusPayload(Map<String, dynamic>.from(focus));
    }
  }

  void _startStaleCheckTimer() {
    _staleCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final now = DateTime.now();
      var hasChanges = false;

      markersMap.forEach((id, marker) {
        if (marker.role == 'DRIVER' && marker.live) {
          final lastTs = marker.deviceTs ?? marker.receivedTs;
          if (lastTs != null && now.difference(lastTs).inSeconds > 30) {
            markersMap[id] = marker.copyWith(live: false);
            hasChanges = true;
          }
        }
      });

      if (hasChanges) markersMap.refresh();
    });
  }

  Future<void> fetchViewportMarkers({
    required LatLngBounds bounds,
    required double zoom,
    bool debounce = true,
  }) async {
    final north = bounds.northeast.latitude;
    final south = bounds.southwest.latitude;
    final east = bounds.northeast.longitude;
    final west = bounds.southwest.longitude;
    // Google Maps can report inverted/zero regions mid-animation.
    if (north <= south || east <= west) {
      debugPrint(
        '⚠️ [Map] skip viewport fetch — invalid bounds '
        'n=$north s=$south e=$east w=$west',
      );
      return;
    }

    _lastBounds = bounds;
    _lastZoom = zoom;
    _cameraDebounceTimer?.cancel();
    final delay = debounce ? const Duration(milliseconds: 400) : Duration.zero;
    _cameraDebounceTimer = Timer(delay, () async {
      try {
        isLoading.value = true;
        final response = await _apiService.get(
          ApiConstants.mapLocations,
          queryParameters: {
            'north': north,
            'south': south,
            'east': east,
            'west': west,
            'zoom': zoom.round().clamp(1, 22),
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = _extractMapPayload(response.data);
          if (data is Map<String, dynamic>) {
            if (data['clusters'] is List) {
              clustersList.assignAll(
                (data['clusters'] as List)
                    .whereType<Map>()
                    .map(
                      (item) => MapClusterModel.fromJson(
                        Map<String, dynamic>.from(item),
                      ),
                    )
                    .where(_hasValidCoordinates)
                    .toList(),
              );
            } else {
              clustersList.clear();
            }

            final nextMarkers = <String, MapMarkerModel>{};
            if (data['markers'] is List) {
              for (final item in data['markers'] as List) {
                if (item is! Map) continue;
                final marker = MapMarkerModel.fromJson(
                  Map<String, dynamic>.from(item),
                );
                if (!_hasValidCoordinates(marker)) continue;

                if (marker.role == 'DRIVER') {
                  final driverKey = marker.driverId ?? marker.id;
                  final socketMarker = _socketDriverMarkers[driverKey];
                  if (_isSocketMarkerNewer(socketMarker, marker) &&
                      _isInsideLastBounds(socketMarker!)) {
                    nextMarkers[driverKey] = socketMarker;
                    continue;
                  }
                  nextMarkers[driverKey] = marker;
                  continue;
                }
                nextMarkers[marker.id] = marker;
              }
            }

            _socketDriverMarkers.forEach((driverId, marker) {
              if (_isInsideLastBounds(marker)) {
                nextMarkers.putIfAbsent(driverId, () => marker);
              }
            });

            if (nextMarkers.isEmpty &&
                clustersList.isEmpty &&
                overview.value.totalCount > 0 &&
                !_retriedEmptyViewport) {
              _retriedEmptyViewport = true;
              final focusBounds = preferredBounds.value;
              final focusCenter = preferredCenter.value;
              if (focusBounds != null) {
                fetchViewportMarkers(
                  bounds: focusBounds,
                  zoom: preferredZoom.value,
                  debounce: false,
                );
                return;
              }
              if (focusCenter != null) {
                // Hub focus has no bounds — query a metro box around the hub.
                final pad = 0.08;
                fetchViewportMarkers(
                  bounds: LatLngBounds(
                    southwest: LatLng(
                      focusCenter.latitude - pad,
                      focusCenter.longitude - pad,
                    ),
                    northeast: LatLng(
                      focusCenter.latitude + pad,
                      focusCenter.longitude + pad,
                    ),
                  ),
                  zoom: preferredZoom.value,
                  debounce: false,
                );
                return;
              }
            } else if (nextMarkers.isNotEmpty || clustersList.isNotEmpty) {
              _retriedEmptyViewport = false;
            }

            markersMap.assignAll(nextMarkers);
            markerCount.value = nextMarkers.length;
          }
        }
      } catch (e) {
        liveUpdatesUnavailable.value = !_socketService.isConnected.value;
        debugPrint('❌ [Map] viewport fetch error: $e');
      } finally {
        isLoading.value = false;
      }
    });
  }

  dynamic _extractMapPayload(dynamic responseData) {
    if (responseData is List) {
      return {'clusters': <dynamic>[], 'markers': responseData};
    }
    if (responseData is Map) {
      final data = Map<String, dynamic>.from(responseData);
      final nested = data['data'];
      if (nested is Map &&
          (nested.containsKey('markers') || nested.containsKey('clusters'))) {
        return Map<String, dynamic>.from(nested);
      }
      return data;
    }
    return null;
  }

  bool _hasValidCoordinates(dynamic item) {
    final lat = item.lat as double;
    final lng = item.lng as double;
    return lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180 &&
        (lat != 0 || lng != 0);
  }

  bool _isSocketMarkerNewer(
    MapMarkerModel? socketMarker,
    MapMarkerModel restMarker,
  ) {
    if (socketMarker == null) return false;
    if (socketMarker.deviceTs == null || restMarker.deviceTs == null) {
      return socketMarker.live;
    }
    return socketMarker.deviceTs!.isAfter(restMarker.deviceTs!);
  }

  bool _isInsideLastBounds(MapMarkerModel marker) {
    final bounds = _lastBounds;
    if (bounds == null) return true;
    return marker.lat <= bounds.northeast.latitude &&
        marker.lat >= bounds.southwest.latitude &&
        marker.lng <= bounds.northeast.longitude &&
        marker.lng >= bounds.southwest.longitude;
  }

  void _upsertSosAlert(Map<String, dynamic> sosData) {
    if (sosData['lat'] == null ||
        (sosData['lng'] == null && sosData['lon'] == null)) {
      return;
    }

    final marker = MapMarkerModel.fromJson({
      ...sosData,
      'role': 'SOS',
      'lng': sosData['lng'] ?? sosData['lon'],
      'name': sosData['name'] ?? 'SOS Alert',
      'detail': sosData['detail'] ?? sosData['message'],
      'live': true,
    });

    if (marker.id.isEmpty || !_isInsideLastBounds(marker)) return;
    markersMap[marker.id] = marker;
    markerCount.value = markersMap.length;
  }

  void _showSosAlert(Map<String, dynamic> sosData) {
    Get.snackbar(
      'Emergency SOS Alert',
      (sosData['message'] ?? 'Emergency assistance requested').toString(),
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 8),
      snackPosition: SnackPosition.TOP,
      isDismissible: false,
    );
  }

  /// Drivers emit GPS while the map is open (backend `location:ping`).
  void publishDriverLocation({
    required double lat,
    required double lon,
    double? speed,
    double? heading,
  }) {
    if (!session.value.isDriver) return;
    _socketService.pingLocation(
      lat: lat,
      lon: lon,
      speed: speed,
      heading: heading,
      deviceTs: DateTime.now().toUtc(),
    );
  }

  @override
  void onClose() {
    _locationSub?.cancel();
    _sosSub?.cancel();
    _mapFocusSub?.cancel();
    _connectedSub?.cancel();
    _cameraDebounceTimer?.cancel();
    _staleCheckTimer?.cancel();
    _socketService.disconnect();
    super.onClose();
  }
}
