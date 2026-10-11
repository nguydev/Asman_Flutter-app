import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _pushAlerts = ValueNotifier<bool>(true);
  final _emailReports = ValueNotifier<bool>(true);
  final _emergencySms = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _pushAlerts.dispose();
    _emailReports.dispose();
    _emergencySms.dispose();
    super.dispose();
  }

  Widget _buildSwitchRow({
    required String title,
    required ValueNotifier<bool> controller,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: title,
                fontSize: 14.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
              AdvancedSwitch(
                controller: controller,
                activeColor: const Color(0xFF38BDF8),
                inactiveColor: const Color(0xFFE2E8F0),
                width: 44,
                height: 24,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(color: const Color(0xFFDFE3E7), height: 1, indent: 0, endIndent: 0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: CustomText(
          text: 'Notifications',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20.r),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          children: [
            CustomContainer(
              color: AppColors.white,
              radiusAll: 12.r,
              border: Border.all(color: const Color(0xFFDFE3E7), width: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                    child: CustomText(
                      text: 'Notifications',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Divider(color: const Color(0xFFDFE3E7), height: 1, indent: 0, endIndent: 0),
                  _buildSwitchRow(
                    title: 'Push Alerts',
                    controller: _pushAlerts,
                  ),
                  _buildSwitchRow(
                    title: 'Email Reports',
                    controller: _emailReports,
                  ),
                  _buildSwitchRow(
                    title: 'Emergency SMS',
                    controller: _emergencySms,
                    showDivider: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
