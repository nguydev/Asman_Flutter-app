import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';

class OnboardingFeatureItem extends StatelessWidget {
  const OnboardingFeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description, this.iconColor,
  });

  final IconData icon;
  final Color? iconColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      marginBottom: 16.h,
      border: Border.all(color: const Color(0xFFDFE3E7), width: 1),
      radiusAll: 20.r,
      paddingAll: 32.r,
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomContainer(
            width: 56.w,
            height: 56.w,
            color: iconColor?.withValues(alpha: 0.1) ?? AppColors.primary.withValues(alpha: 0.1),
            radiusAll: 12.r,
            child: Icon(icon, size: 24.sp, color: iconColor ?? AppColors.primary),
          ),
          SizedBox(height: 24.w),
          CustomText(
            text: title,
            textAlign: TextAlign.start,
            fontSize: 24.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 12.h),
          CustomText(
            text: description,
            textAlign: TextAlign.start,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
