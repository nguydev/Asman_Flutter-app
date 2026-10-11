import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:flutter_task/features/profile/presentation/widgets/profile_menu_tile.dart';
import 'package:flutter_task/widgets/widgets.dart';

class ProfileMenuSection extends StatelessWidget {
  final String title;
  final List<ProfileMenuItem> items;

  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
            child: CustomText(
              text: title,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              textAlign: TextAlign.left,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++)
                    ProfileMenuTile(
                      iconPath: items[i].iconPath,
                      title: items[i].title,
                      onTap: items[i].onTap,
                      showDivider: i < items.length - 1,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
