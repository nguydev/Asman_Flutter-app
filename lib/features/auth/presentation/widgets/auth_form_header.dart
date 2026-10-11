import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';

class AuthFormHeader extends StatelessWidget {
  const AuthFormHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = AppColors.secondary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20.h),
        CustomContainer(
          width: 64.r,
          height: 64.r,
          color: AppColors.white,
          radiusAll: 20.r,
          child: Icon(icon, color: iconColor),
        ),
        SizedBox(height: 10.h),
        CustomText(
          text: title,
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 8.h),
        CustomText(
          text: subtitle,
          fontSize: 16.sp,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: 28.h),
      ],
    );
  }
}
