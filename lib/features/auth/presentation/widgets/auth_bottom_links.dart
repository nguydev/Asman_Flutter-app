import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';

class AuthBottomLinks extends StatelessWidget {
  const AuthBottomLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomText(
          text: 'Privacy Policy',
          fontSize: 12.sp,
          color: AppColors.textPrimary,
          onTap: () {},
        ),
        CustomText(
          text: 'Terms of Service',
          fontSize: 12.sp,
          color: AppColors.textPrimary,
          onTap: () {},
        ),
        CustomText(
          text: 'Help Center',
          fontSize: 12.sp,
          color: AppColors.textPrimary,
          onTap: () {},
        ),
      ],
    );
  }
}
