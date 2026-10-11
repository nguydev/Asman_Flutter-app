import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/features/auth/presentation/widgets/auth_brand_title.dart';
import 'package:flutter_task/features/auth/presentation/widgets/auth_form_header.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

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
          icon: Icons.lock_reset_outlined,
          title: 'Reset Password',
          subtitle: 'Create a new secure password for your ASMAN account',
        ),
        CustomTextField(
          controller: authController.passwordController,
          labelText: 'New Password',
          hintText: '••••••••',
          isPassword: true,
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: AppColors.textSecondary,
            size: 20.r,
          ),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: authController.confirmPasswordController,
          labelText: 'Confirm Password',
          hintText: '••••••••',
          isPassword: true,
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: AppColors.textSecondary,
            size: 20.r,
          ),
        ),
        SizedBox(height: 44.h),
        Obx(
          () => CustomButton(
            label: 'Reset Password →',
            isLoading: authController.isLoading.value,
            onPressed: () => authController.resetPassword(),
            backgroundColor: AppColors.primary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
