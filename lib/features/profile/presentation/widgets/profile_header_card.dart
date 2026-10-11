import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter_task/features/profile/presentation/personal_info_screen.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';

class ProfileHeaderCard extends StatelessWidget {
  final ProfileController controller;

  const ProfileHeaderCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.driverProfile.value == null) {
        return Container(
          height: 120.h,
          margin: EdgeInsets.only(bottom: 24.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.divider),
          ),
          alignment: Alignment.center,
          child: const CupertinoActivityIndicator(),
        );
      }

      final profileData = controller.driverProfile.value;

      if (profileData == null) {
        final errorText = controller.errorMessage.value.isNotEmpty
            ? controller.errorMessage.value
            : 'Failed to load profile details.';
        return Container(
          margin: EdgeInsets.only(bottom: 24.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomText(
                text: errorText,
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                textAlign: TextAlign.left,
                textHeight: 1.4,
              ),
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => controller.fetchDriverProfile(),
                  child: CustomText(
                    text: 'Retry',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final name = profileData.profile?.name?.trim().isNotEmpty == true
          ? profileData.profile!.name!.trim()
          : 'No Name';
      final email = profileData.email?.trim().isNotEmpty == true
          ? profileData.email!.trim()
          : null;
      final phone = profileData.phone?.trim().isNotEmpty == true
          ? profileData.phone!.trim()
          : null;
      final avatarUrl = profileData.profile?.avatarUrl ?? '';
      final plate = profileData.driver?.licensePlate?.trim();
      final vin = profileData.driver?.vinNumber?.trim();

      final metaParts = <String>[
        if (plate != null && plate.isNotEmpty) plate,
        if (vin != null && vin.isNotEmpty) 'VIN $vin',
      ];

      return Padding(
        padding: EdgeInsets.only(bottom: 24.h),
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            onTap: () => Get.to(() => const PersonalInfoScreen()),
            borderRadius: BorderRadius.circular(12.r),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.divider),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 18.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.divider,
                          width: 1,
                        ),
                      ),
                      padding: EdgeInsets.all(2.r),
                      child: PresignedNetworkImage(
                        imageUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
                        height: 72.r,
                        width: 72.r,
                        boxShape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: name,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            textAlign: TextAlign.left,
                            maxline: 2,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                          if (email != null) ...[
                            SizedBox(height: 6.h),
                            CustomText(
                              text: email,
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                              textAlign: TextAlign.left,
                              maxline: 1,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (phone != null) ...[
                            SizedBox(height: 4.h),
                            CustomText(
                              text: phone,
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                              textAlign: TextAlign.left,
                              maxline: 1,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (metaParts.isNotEmpty) ...[
                            SizedBox(height: 10.h),
                            CustomText(
                              text: metaParts.join('  ·  '),
                              fontSize: 12.sp,
                              color: AppColors.textHint,
                              textAlign: TextAlign.left,
                              maxline: 1,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
