import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';

class ProfileCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const ProfileCard({
    super.key,
    required this.title,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      radiusAll: 20,
      paddingAll: 20.r,
      elevation: true,
      elevationColor: AppColors.black.withValues(alpha: 0.04),
      marginBottom: 16.h,
      border: Border.all(color: const Color(0xFFDFE3E7), width: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: title,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}
