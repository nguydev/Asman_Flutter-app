import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';

class DetentionAlertDialog extends StatelessWidget {
  const DetentionAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, color: AppColors.textSecondary, size: 24.r),
              ),
            ),
            
            // Alert Icon
            Container(
              height: 80.r,
              width: 80.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.warning_rounded,
                color: const Color(0xFFC62828), // Dark red
                size: 40.r,
              ),
            ),
            SizedBox(height: 16.h),
            
            // High Alert Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2), // Light red bg
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: CustomText(
                text: 'HIGH ALERT',
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFDC2626),
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Title
            CustomText(
              text: 'Detention Center\nAhead',
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            
            // Description
            CustomText(
              text: 'Proactive identification of a high-risk zone. Nearby legal assistance is available for immediate consultation.',
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            
            // Distance Card
            _buildInfoCard(
              icon: Icons.near_me_outlined,
              iconColor: const Color(0xFF0284C7),
              title: 'DISTANCE',
              value: '0.8 miles\naway',
            ),
            SizedBox(height: 12.h),
            
            // Network Card
            _buildInfoCard(
              icon: Icons.gavel_outlined, // Using gavel as attorney icon placeholder
              iconColor: const Color(0xFF10B981),
              title: 'ACTIVE NETWORK',
              value: '2 Attorneys',
            ),
            SizedBox(height: 24.h),
            
            // Dismiss Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: CustomText(
                text: 'Dismiss Notification',
                fontSize: 14.sp,
                color: AppColors.textSecondary,
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
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Very light grey/blue
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFC5C6CD)),
      ),
      child: Row(
        children: [
          Container(
            height: 40.r,
            width: 40.r,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 20.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  text: value,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
