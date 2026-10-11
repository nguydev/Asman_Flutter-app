import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_task/core/services/location_service.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/features/map/data/models/map_marker_model.dart';
import 'package:flutter_task/features/map/data/models/map_session.dart';
import 'package:flutter_task/features/map/presentation/controller/map_controller.dart';
import 'package:flutter_task/features/map/presentation/map_navigation_screen.dart';
import 'package:flutter_task/features/notifications/presentation/notifications_screen.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _googleMapController;
  double _currentZoom = MapSession.seedHubZoom;
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final MapFeatureController _mapController = Get.put(MapFeatureController());
  Worker? _socketFocusWorker;

  bool _mapReady = false;
  LatLng? _userLocation;

  static const LatLng _kFallbackCenter = LatLng(
    MapSession.seedHubLat,
    MapSession.seedHubLng,
  );

  @override
  void initState() {
    super.initState();
    _socketFocusWorker = ever<int>(
      _mapController.socketFocusRevision,
      (_) => unawaited(_applyPreferredFocus(fetchMarkers: true)),
    );
  }

  @override
  void dispose() {
    _socketFocusWorker?.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _googleMapController?.dispose();
    super.dispose();
  }

  Future<void> _centerMapOnUserLocation({bool isInitial = false}) async {
    final userLoc = await LocationService().getCurrentLocation();
    if (!mounted || userLoc == null) return;

    final target = LatLng(userLoc.latitude, userLoc.longitude);
    setState(() => _userLocation = target);

    _mapController.publishDriverLocation(
      lat: userLoc.latitude,
      lon: userLoc.longitude,
    );

    if (!_mapReady) return;
    _currentZoom = isInitial ? 14.5 : 14.0;
    await _googleMapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, _currentZoom),
    );
    await _fetchViewportMarkers();
  }

  void _centerOnFleetHub() {
    if (!_mapReady) return;
    unawaited(() async {
      await _fitOverviewCamera(refresh: true);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await _fetchViewportMarkers();
    }());
  }

  void _onMapReady(GoogleMapController controller) {
    _googleMapController = controller;
    _mapReady = true;
    unawaited(_loadInitialViewport());
  }

  Future<void> _loadInitialViewport() async {
    // Wait for session + overview so we know where the fleet actually is.
    var waited = 0;
    while ((_mapController.sessionLoading.value ||
            _mapController.overviewLoading.value) &&
        waited < 40) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      waited++;
    }

    // Google Maps rejects newLatLngBounds until the platform view has size.
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted || !_mapReady) return;

    final fitted = await _fitOverviewCamera(refresh: false);
    if (!fitted) {
      // Prefer org hub over device GPS — GPS is often far from the fleet.
      final hub = _mapController.preferredCenter.value;
      if (hub != null) {
        _currentZoom = _mapController.preferredZoom.value;
        await _googleMapController?.animateCamera(
          CameraUpdate.newLatLngZoom(hub, _currentZoom),
        );
      } else {
        await _tryCenterUser();
      }
    }

    // Keep GPS blue-dot / driver ping without overriding the fleet frame.
    unawaited(_centerMapOnUserLocationQuiet());

    await Future<void>.delayed(const Duration(milliseconds: 250));
    await _fetchViewportMarkers();
  }

  /// Fit camera using sanitized preferred bounds/center from overview.
  Future<bool> _fitOverviewCamera({required bool refresh}) async {
    if (!_mapReady) return false;
    if (refresh) {
      await _mapController.fetchOverview();
    }
    return _applyPreferredFocus(fetchMarkers: false);
  }

  Future<void> _animateToBoundsOrCenter({
    required LatLngBounds bounds,
    required LatLng? center,
    required double zoom,
  }) async {
    try {
      await _googleMapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 48),
      );
    } catch (e) {
      final fallbackCenter =
          center ??
          LatLng(
            (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
            (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
          );
      debugPrint('⚠️ [Map] bounds camera failed, using center zoom: $e');
      await _googleMapController?.animateCamera(
        CameraUpdate.newLatLngZoom(fallbackCenter, zoom),
      );
    }
  }

  /// Moves camera to controller preferredBounds / preferredCenter.
  /// Returns true when a preferred target was applied.
  Future<bool> _applyPreferredFocus({bool fetchMarkers = true}) async {
    if (!_mapReady || _googleMapController == null) return false;

    final bounds = _mapController.preferredBounds.value;
    if (bounds != null) {
      _currentZoom = _mapController.preferredZoom.value;
      await _animateToBoundsOrCenter(
        bounds: bounds,
        center: _mapController.preferredCenter.value,
        zoom: _currentZoom,
      );
      if (fetchMarkers) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await _fetchViewportMarkers();
      }
      return true;
    }

    final center = _mapController.preferredCenter.value;
    if (center != null) {
      _currentZoom = _mapController.preferredZoom.value;
      await _googleMapController?.animateCamera(
        CameraUpdate.newLatLngZoom(center, _currentZoom),
      );
      if (fetchMarkers) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await _fetchViewportMarkers();
      }
      return true;
    }

    return false;
  }

  Future<void> _centerMapOnUserLocationQuiet() async {
    final userLoc = await LocationService().getCurrentLocation();
    if (!mounted || userLoc == null) return;
    setState(() {
      _userLocation = LatLng(userLoc.latitude, userLoc.longitude);
    });
    _mapController.publishDriverLocation(
      lat: userLoc.latitude,
      lon: userLoc.longitude,
    );
  }

  Future<bool> _tryCenterUser() async {
    final userLoc = await LocationService().getCurrentLocation();
    if (!mounted || userLoc == null || !_mapReady) return false;
    final target = LatLng(userLoc.latitude, userLoc.longitude);
    setState(() => _userLocation = target);
    _currentZoom = 14.5;
    await _googleMapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, _currentZoom),
    );
    _mapController.publishDriverLocation(
      lat: userLoc.latitude,
      lon: userLoc.longitude,
    );
    return true;
  }

  Future<void> _fetchViewportMarkers() async {
    if (!_mapReady || _googleMapController == null) return;
    final bounds = await _googleMapController!.getVisibleRegion();
    _mapController.fetchViewportMarkers(bounds: bounds, zoom: _currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Obx(
            () => GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: const CameraPosition(
                target: _kFallbackCenter,
                zoom: MapSession.seedHubZoom,
              ),
              minMaxZoomPreference: const MinMaxZoomPreference(3, 18),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              markers: _buildMapMarkers(),
              onMapCreated: _onMapReady,
              onCameraMove: (position) => _currentZoom = position.zoom,
              onCameraIdle: () => unawaited(_fetchViewportMarkers()),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFDFE3E7), width: 1),
                ),
              ),
              padding: EdgeInsets.only(
                top: 48.h,
                bottom: 12.h,
                left: 16.w,
                right: 16.w,
              ),
              child: Obx(() {
                final s = _mapController.session.value;
                return Column(
                  children: [
                    CustomText(
                      text: 'Map',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    if (s.displayName != null && s.displayName!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      CustomText(
                        text: s.displayName!,
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ],
                );
              }),
            ),
          ),

          // Positioned(
          //   top: 100.h,
          //   left: 20.w,
          //   right: 20.w,
          //   child: CustomContainer(
          //     color: const Color(0xFFE2E8F0).withValues(alpha: 0.9),
          //     radiusAll: 16,
          //     paddingAll: 16.r,
          //     child: Row(
          //       children: [
          //         Column(
          //           children: [
          //             Icon(
          //               Icons.circle,
          //               color: const Color(0xFF0EA5E9),
          //               size: 12.r,
          //             ),
          //             Container(
          //               height: 24.h,
          //               width: 2.w,
          //               color: const Color(0xFFCBD5E1),
          //             ),
          //             Icon(
          //               Icons.location_on_outlined,
          //               color: const Color(0xFFEF4444),
          //               size: 16.r,
          //             ),
          //           ],
          //         ),
          //         SizedBox(width: 12.w),
          //         Expanded(
          //           child: Column(
          //             children: [
          //               CustomContainer(
          //                 height: 40.h,
          //                 width: double.infinity,
          //                 color: const Color(0xFFF1F5F9),
          //                 radiusAll: 8,
          //                 alignment: Alignment.centerLeft,
          //                 child: TextField(
          //                   controller: _originController,
          //                   style: TextStyle(
          //                     fontSize: 14.sp,
          //                     color: AppColors.textPrimary,
          //                   ),
          //                   decoration: InputDecoration(
          //                     contentPadding: EdgeInsets.symmetric(
          //                       horizontal: 12.w,
          //                     ),
          //                     border: InputBorder.none,
          //                     isDense: true,
          //                     hintText: 'Origin',
          //                   ),
          //                 ),
          //               ),
          //               SizedBox(height: 8.h),
          //               CustomContainer(
          //                 height: 40.h,
          //                 width: double.infinity,
          //                 color: const Color(0xFFF1F5F9),
          //                 radiusAll: 8,
          //                 alignment: Alignment.centerLeft,
          //                 child: TextField(
          //                   controller: _destinationController,
          //                   style: TextStyle(
          //                     fontSize: 14.sp,
          //                     color: AppColors.textPrimary,
          //                   ),
          //                   decoration: InputDecoration(
          //                     contentPadding: EdgeInsets.symmetric(
          //                       horizontal: 12.w,
          //                     ),
          //                     border: InputBorder.none,
          //                     isDense: true,
          //                     hintText: 'Destination',
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          Obx(() {
            final s = _mapController.session.value;
            final liveDown = _mapController.liveUpdatesUnavailable.value;
            final empty =
                !_mapController.sessionLoading.value &&
                !_mapController.overviewLoading.value &&
                !_mapController.isLoading.value &&
                (_mapController.overview.value.empty ||
                    (_mapController.markersMap.isEmpty &&
                        _mapController.clustersList.isEmpty));

            if (!liveDown && !empty) {
              return const SizedBox.shrink();
            }

            return Positioned(
              top: 220.h,
              left: 20.w,
              right: 84.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (liveDown)
                    CustomContainer(
                      color: const Color(0xFFFEF2F2),
                      radiusAll: 8,
                      paddingAll: 12.r,
                      child: Row(
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            color: const Color(0xFFDC2626),
                            size: 18.r,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: CustomText(
                              text:
                                  'Live updates unavailable. Showing latest map data.',
                              fontSize: 12.sp,
                              color: const Color(0xFF991B1B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (empty) ...[
                    if (liveDown) SizedBox(height: 8.h),
                    CustomContainer(
                      color: const Color(0xFFFFFBEB),
                      radiusAll: 8,
                      paddingAll: 12.r,
                      child: CustomText(
                        text: s.emptyStateMessage,
                        fontSize: 12.sp,
                        color: const Color(0xFF92400E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          Positioned(
            top: 140.h,
            right: 20.w,
            child: Column(
              children: [
                _buildFloatingActionButton(
                  icon: Icons.apartment_rounded,
                  onTap: _centerOnFleetHub,
                ),
                SizedBox(height: 12.h),
                _buildFloatingActionButton(
                  icon: Icons.my_location,
                  onTap: () => _centerMapOnUserLocation(),
                ),
                SizedBox(height: 12.h),
                _buildFloatingActionButton(
                  icon: Icons.notifications_none_outlined,
                  assetIcon: 'assets/icons/notification-bing.svg',
                  showBadge: true,
                  onTap: () {
                    Get.to(() => const NotificationsScreen());
                  },
                ),
              ],
            ),
          ),

          // Positioned(
          //   top: 1.sh - 170.h,
          //   left: 20.w,
          //   right: 20.w,
          //   child: CustomButton(
          //     onPressed: () {
          //       Get.to(() => const MapNavigationScreen());
          //     },
          //     label: 'Start Navigation',
          //     backgroundColor: const Color(0xFF0F172A),
          //     foregroundColor: AppColors.white,
          //     radius: 12.r,
          //     height: 56.h,
          //     prefixIcon: Icon(
          //       Icons.navigation_outlined,
          //       color: AppColors.white,
          //       size: 20.r,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton({
    IconData? icon,
    String? assetIcon,
    bool showBadge = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.r,
        width: 48.r,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (assetIcon != null)
              SvgPicture.asset(
                assetIcon,
                width: 24.r,
                height: 24.r,
                colorFilter: ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              )
            else if (icon != null)
              Icon(icon, color: AppColors.textPrimary, size: 24.r),
            if (showBadge)
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  height: 8.r,
                  width: 8.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Set<Marker> _buildMapMarkers() {
    final markers = <Marker>{};

    _mapController.markersMap.forEach((id, item) {
      markers.add(
        Marker(
          markerId: MarkerId(id),
          position: LatLng(item.lat, item.lng),
          rotation: item.heading ?? 0,
          icon: BitmapDescriptor.defaultMarkerWithHue(_markerHue(item)),
          infoWindow: InfoWindow(
            title: item.name ?? item.role,
            snippet: _markerSnippet(item),
          ),
          onTap: item.role == 'ORGANIZATION'
              ? () => unawaited(_focusOrganization(item))
              : null,
        ),
      );
    });

    for (int i = 0; i < _mapController.clustersList.length; i++) {
      final cluster = _mapController.clustersList[i];
      markers.add(
        Marker(
          markerId: MarkerId('cluster_$i'),
          position: LatLng(cluster.lat, cluster.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: cluster.count == 1
                ? '1 location nearby'
                : '${cluster.count} locations nearby',
            snippet: 'Tap to zoom in',
          ),
          onTap: () => _zoomIntoGroup(cluster),
        ),
      );
    }

    final userLocation = _userLocation;
    if (userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_user_location'),
          position: userLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: 'Current location'),
        ),
      );
    }

    return markers;
  }

  double _markerHue(MapMarkerModel item) {
    switch (item.role) {
      case 'ORGANIZATION':
        return BitmapDescriptor.hueGreen;
      case 'ATTORNEY':
        return BitmapDescriptor.hueViolet;
      case 'SOS':
        return BitmapDescriptor.hueRed;
      case 'DRIVER':
      default:
        return item.live ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueAzure;
    }
  }

  String _markerSnippet(MapMarkerModel item) {
    if (item.role == 'DRIVER') {
      final speed = item.speed != null
          ? '${item.speed!.toStringAsFixed(1)} mph - '
          : '';
      return '$speed${item.live ? "Live" : "Offline"}';
    }
    if (item.role == 'SOS') {
      return item.detail ?? item.status ?? 'Emergency assistance requested';
    }
    final location = [
      item.city,
      item.state,
    ].whereType<String>().where((value) => value.isNotEmpty).join(', ');
    return location.isEmpty ? item.role : location;
  }

  Future<void> _focusOrganization(MapMarkerModel organization) async {
    final focused = await _mapController.focusOrganization(organization.id);
    if (focused) {
      await _applyPreferredFocus();
      return;
    }

    _currentZoom = 15;
    await _googleMapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(organization.lat, organization.lng),
        _currentZoom,
      ),
    );
    await _fetchViewportMarkers();
  }

  void _zoomIntoGroup(MapClusterModel group) {
    if (!_mapReady) return;
    _currentZoom = (_currentZoom + 2).clamp(10, 18).toDouble();
    unawaited(
      _googleMapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(group.lat, group.lng),
              _currentZoom,
            ),
          ) ??
          Future<void>.value(),
    );
  }
}
