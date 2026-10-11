import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/services/cache_service.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';

class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({super.key});

  static Future<void> show() {
    return Get.dialog(const LogoutConfirmDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomContainer(
              height: 48.r,
              width: 48.r,
              radiusAll: 24.r,
              color: const Color(0xFFf87171),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/logout.svg',
                width: 20.r,
                height: 20.r,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: 'Log Out',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 4.h),
            CustomText(
              text: 'Are you sure you want to log out of this account?',
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
              textHeight: 1.5,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () => Get.back(),
                    label: 'Cancel',
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.textPrimary,
                    bordersColor: const Color(0xFF9CA3AF),
                    borderWidth: 1,
                    radius: 12.r,
                    height: 48.h,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    onPressed: () async {
                      Get.back();
                      await Get.find<CacheService>().clear();
                      Get.offAllNamed(AppRoutes.login);
                    },
                    label: 'Log Out',
                    backgroundColor: const Color(0xFFf87171),
                    foregroundColor: AppColors.white,
                    radius: 12.r,
                    height: 48.h,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
