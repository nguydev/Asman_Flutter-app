import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/assets.gen.dart';
import 'package:flutter_task/widgets/widgets.dart';

class AuthBrandTitle extends StatelessWidget {
  const AuthBrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Assets.images.logo.image(height: 32.r, width: 32.r),
        CustomText(
          left: 6.w,
          text: 'asman'.toUpperCase(),
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }
}
