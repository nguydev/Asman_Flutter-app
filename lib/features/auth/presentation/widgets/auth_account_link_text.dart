import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';

class AuthAccountLinkText extends StatelessWidget {
  const AuthAccountLinkText({
    super.key,
    required this.prefix,
    required this.action,
    required this.onActionTap,
  });

  final String prefix;
  final String action;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.textSecondary,
          fontFamily: 'Inter',
        ),
        children: [
          TextSpan(text: prefix),
          TextSpan(
            text: action,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
            recognizer: TapGestureRecognizer()..onTap = onActionTap,
          ),
        ],
      ),
    );
  }
}
