import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animarker/widgets/animarker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_task/features/map/presentation/truck_stop_details_screen.dart';
import 'package:flutter_task/core/helpers/marker_helper.dart';
import 'package:flutter_task/features/bottom_nav_bar/presentation/main_bottom_nav_bar.dart';
import 'package:flutter_task/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:flutter_task/features/map/presentation/controller/uber_navigation_controller.dart';
import 'package:flutter_task/core/constants/map_constants.dart';

class MapNavigationScreen extends StatefulWidget {
  const MapNavigationScreen({super.key});

  @override
  State<MapNavigationScreen> createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final UberNavigationController _navController = Get.put(UberNavigationController());

  final Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  static const LatLng _origin = LatLng(34.0407, -118.2468);
  static const LatLng _destination = LatLng(34.0092, -118.4976);

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: _origin,
    zoom: 17.5,
    tilt: 45.0,
  );
  BitmapDescriptor? _truckMarkerIcon;

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints(apiKey: MapConstants.googleMapsApiKey);
    _setPolylines();
    _loadCustomMarker();
    _navController.startUberNavigationStream();
  }

  Future<void> _loadCustomMarker() async {
    final icon = await MarkerHelper.createCustomMarkerBitmap(
      Icons.local_shipping,
      size: 44.0,
      circleColor: const Color(0xFF2563EB), // Tailwind Blue 600
    );
    if (mounted) {
      setState(() {
        _truckMarkerIcon = icon;
      });
    }
  }

  void _setPolylines() async {
    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(_origin.latitude, _origin.longitude),
          destination: PointLatLng(_destination.latitude, _destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates.clear();
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        setState(() {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              color: const Color(0xFF3B82F6), // Blue route color
              width: 6,
              points: polylineCoordinates,
            ),
          );
        });
      }
    } catch (e) {
      debugPrint("Error fetching polyline: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Obx(() {
            final pos = _navController.currentPosition.value;
            final driverLatLng = pos != null ? LatLng(pos.latitude, pos.longitude) : _origin;

            final animarkerMarkers = <Marker>{
              Marker(
                markerId: const MarkerId('driver_uber_marker'),
                position: driverLatLng,
                rotation: _navController.currentHeading.value,
                icon: _truckMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                infoWindow: InfoWindow(
                  title: 'My Vehicle',
                  snippet: pos != null ? '${(pos.speed * 2.23694).toStringAsFixed(1)} mph' : 'Navigating',
                ),
              ),
              Marker(
                markerId: const MarkerId('destination'),
                position: _destination,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
            };

            return Animarker(
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 1000), // Uber-like 1s smooth position interpolation
              markers: animarkerMarkers,
              mapId: _controller.future.then((c) => c.mapId),
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _kInitialPosition,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                polylines: _polylines,
                onMapCreated: (GoogleMapController controller) {
                  if (!_controller.isCompleted) {
                    _controller.complete(controller);
                    _navController.onMapCreated(controller);
                  }
                },
              ),
            );
          }),
          
          // Custom App Bar
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
              padding: EdgeInsets.only(top: 48.h, bottom: 16.h, left: 16.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back_ios_new, size: 20.r, color: AppColors.textPrimary),
                  ),
                  Expanded(
                    child: Center(
                      child: CustomText(
                        text: 'Map',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 36.w), // To balance the back arrow
                ],
              ),
            ),
          ),

          // Action Buttons (Right Side)
          Positioned(
            bottom: 100.h,
            right: 20.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // List View Button
                GestureDetector(
                  onTap: () => _showListViewBottomSheet(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8), // Light Blue
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.view_list_outlined, color: Colors.white, size: 20.r),
                        SizedBox(width: 8.w),
                        CustomText(
                          text: 'List view',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // SOS Button
                GestureDetector(
                  onTap: () {
                    Get.find<BottomNavBarController>().onChange(0);
                    Get.offAll(() => const MainBottomNavBar());
                  },
                  child: Container(
                    height: 56.r,
                    width: 56.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC62828),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC62828).withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: CustomText(
                      text: 'SOS',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showListViewBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 48.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  itemCount: 4,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.to(() => const TruckStopDetailsScreen());
                      },
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                        ),
                      child: Row(
                        children: [
                          Container(
                            height: 48.r,
                            width: 48.r,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: const Color(0xFFDFE3E7)),
                            ),
                            child: Icon(
                              Icons.local_gas_station_outlined,
                              color: AppColors.textPrimary,
                              size: 24.r,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: 'Border Patrol Station4',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                SizedBox(height: 4.h),
                                CustomText(
                                  text: '0.9 miles away',
                                  fontSize: 13.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: CustomText(
                              text: 'In Range',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      )
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
