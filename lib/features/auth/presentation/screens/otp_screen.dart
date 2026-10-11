import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/features/auth/presentation/widgets/auth_brand_title.dart';
import 'package:flutter_task/features/auth/presentation/widgets/auth_form_header.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return SliverScaffold(
      appBar: CustomSliverAppBar(
        titleWidget: const AuthBrandTitle(),
      ),
      bodyList: [
        _buildFormCard(authController).asSliverWithPadding(horizontal: 16.w),
        SizedBox(height: 80.h).asSliver,
      ],
    );
  }

  Widget _buildFormCard(AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthFormHeader(
          icon: Icons.verified_outlined,
          title: 'Verify OTP',
          subtitle:
              'Enter the code sent to your registered email address',
        ),
        CustomPinCodeTextField(
          controller: authController.otpController,
        ),
        SizedBox(height: 16.h),
        CustomText(
          text: "Didn't receive the code? Resend OTP",
          fontSize: 14.sp,
          color: AppColors.textSecondary,
          onTap: () {
            authController.resendOtp();
          },
        ),
        SizedBox(height: 44.h),
        Obx(
          () => CustomButton(
            label: 'Verify OTP →',
            isLoading: authController.isLoading.value,
            onPressed: () {
              authController.verifyOtp(authController.otpController.text.trim());
            },
            backgroundColor: AppColors.primary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
