import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_task/features/map/presentation/map_navigation_screen.dart';

class TruckStopDetailsScreen extends StatelessWidget {
  const TruckStopDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FC), // Light background similar to SOS screen
      appBar: AppBar(
        title: CustomText(
          text: 'Truck Stop Details',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.r, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Color(0xFFDFE3E7),
            width: 1,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32.r),
            bottomRight: Radius.circular(32.r),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Hero Image Section
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Container(
                        height: 240.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(16.r),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1586864387967-d02ef85d93e8?auto=format&fit=crop&q=80&w=1000',
                            ),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                        ),
                      ),
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: CustomText(
                                  text: 'OPEN 24/7',
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: CustomText(
                                  text: 'HIGH AVAILABILITY',
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          CustomText(
                            text: 'Blue Diamond Logistics Plaza',
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          SizedBox(height: 4.h),
                          CustomText(
                            text: 'Exit 142 • I-95 Northbound • Savannah, GA',
                            fontSize: 12.sp,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                    ),

                    // Content Padding
                    Padding(
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        children: [
                          // Info Cards Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.local_gas_station_outlined,
                                  iconColor: const Color(0xFF0284C7),
                                  title: 'FUEL',
                                  value: 'ULSD, CNG',
                                  subtitle: 'DEF at every pump',
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.local_parking,
                                  iconColor: const Color(0xFF0284C7),
                                  title: 'PARKING',
                                  value: '42 / 150 Spots',
                                  valueColor: AppColors.textPrimary,
                                  highlightValue: '42 / 150',
                                  subtitle: 'Likely to find spot',
                                  subtitleColor: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),

                          // Real Map
                          CustomContainer(
                            height: 200.h,
                            width: double.infinity,
                            color: const Color(0xFFF1F5F9),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            radiusAll: 12,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: GoogleMap(
                                    mapType: MapType.normal,
                                    initialCameraPosition: const CameraPosition(
                                      target: LatLng(32.0809, -81.0912), // Savannah, GA
                                      zoom: 13.0,
                                    ),
                                    markers: {
                                      const Marker(
                                        markerId: MarkerId('truck_stop'),
                                        position: LatLng(32.0809, -81.0912),
                                      ),
                                    },
                                    zoomControlsEnabled: false,
                                    myLocationButtonEnabled: false,
                                    compassEnabled: false,
                                    mapToolbarEnabled: false,
                                  ),
                                ),
                                Positioned(
                                  top: 16.h,
                                  left: 16.w,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: CustomText(
                                      text: 'Savannah, GA',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Navigate Button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: const Color(0xFFF1F5F9), width: 1),
                ),
              ),
              child: CustomButton(
                onPressed: () {
                  Get.to(() => const MapNavigationScreen());
                },
                label: 'Navigate',
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                radius: 12.r,
                height: 56.h,
                prefixIcon: Icon(Icons.directions, color: Colors.white, size: 20.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    String? highlightValue,
    required String subtitle,
    Color? subtitleColor,
    Color? valueColor,
  }) {
    return CustomContainer(
      color: Colors.white,
      paddingAll: 16.r,
      radiusAll: 12,
      elevation: true,
      elevationColor: Colors.black.withOpacity(0.04),
      border: Border.all(color: const Color(0xFFF1F5F9)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.r, color: iconColor),
              SizedBox(width: 6.w),
              CustomText(
                text: title,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (highlightValue != null)
            RichText(
              text: TextSpan(
                text: '42 / 150 ',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
                children: [
                  TextSpan(
                    text: 'Spots',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            )
          else
            CustomText(
              text: value,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textPrimary,
            ),
          SizedBox(height: 4.h),
          CustomText(
            text: subtitle,
            fontSize: 11.sp,
            color: subtitleColor ?? const Color(0xFF64748B),
          ),
        ],
      ),
    );
  }
}
