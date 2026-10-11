import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/features/auth/presentation/widgets/auth_brand_title.dart';
import 'package:flutter_task/features/auth/presentation/widgets/auth_form_header.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';

class ForgotScreen extends StatelessWidget {
  const ForgotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return SliverScaffold(
      appBar: CustomSliverAppBar(
        flexiblePaddingTop: 20.h,
        expandedHeight: 300.h,
        titleWidget: const AuthBrandTitle(),
        flexibleChild: const AuthFormHeader(
          icon: Icons.mark_email_read_outlined,
          title: 'Forgot Password',
          subtitle: 'Enter your email to receive a password reset OTP',
        ),
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
        CustomTextField(
          controller: authController.emailController,
          labelText: 'Email Address',
          hintText: 'Enter your email',
          isEmail: true,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(
            Icons.email_outlined,
            color: AppColors.textSecondary,
            size: 16.r,
          ),
        ),
        SizedBox(height: 44.h),
        Obx(
          () => CustomButton(
            label: 'Send OTP →',
            isLoading: authController.isLoading.value,
            onPressed: () => authController.forgotPassword(),
            backgroundColor: AppColors.primary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
