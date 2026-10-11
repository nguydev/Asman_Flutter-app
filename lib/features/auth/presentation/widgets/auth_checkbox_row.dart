import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';

class AuthCheckboxRow extends StatelessWidget {
  const AuthCheckboxRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24.h,
          width: 24.w,
          child: Checkbox(
            value: value,
            activeColor: AppColors.primary,
            side: BorderSide(color: AppColors.divider, width: 1.5.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(child: label),
      ],
    );
  }
}

class AuthRememberMeRow extends StatelessWidget {
  const AuthRememberMeRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return AuthCheckboxRow(
      value: value,
      onChanged: onChanged,
      label: CustomText(
        text: 'Remember me for 30 days',
        textAlign: TextAlign.start,
        fontSize: 14.sp,
        color: AppColors.textSecondary,
      ),
    );
  }
}
