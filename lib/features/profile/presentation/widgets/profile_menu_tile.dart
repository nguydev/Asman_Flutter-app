import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';

class ProfileMenuTile extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  const ProfileMenuTile({
    super.key,
    required this.iconPath,
    required this.title,
    required this.onTap,
    this.subtitle = '',
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                SvgPicture.asset(iconPath, width: 22.r, height: 22.r),
                SizedBox(width: 14.w),
                Expanded(
                  child: CustomText(
                    text: title,
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.left,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                  size: 20.r,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            color: AppColors.divider,
            height: 1,
            thickness: 1,
            indent: 52.w,
            endIndent: 0,
          ),
      ],
    );
  }
}
