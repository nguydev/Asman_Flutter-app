import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/core/utils/assets.gen.dart';
import 'package:flutter_task/features/auth/presentation/widgets/auth_account_link_text.dart';
import 'package:flutter_task/features/auth/presentation/widgets/auth_bottom_links.dart';
import 'package:flutter_task/features/auth/presentation/widgets/auth_brand_title.dart';
import 'package:flutter_task/features/auth/presentation/widgets/auth_checkbox_row.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  final _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: CustomSliverAppBar(
        expandedHeight: 380.h,
        titleWidget: const AuthBrandTitle(),
        flexiblePaddingTop: 10.h,
        flexibleChild: Assets.images.login.image(
          width: double.infinity,
          fit: BoxFit.cover,
          height: 306.h,
        ),
      ),
      bodyList: [
        _buildFormCard().asSliverWithPadding(horizontal: 16.w),
        SizedBox(height: 32.h).asSliver,
        AuthAccountLinkText(
          prefix: "Don't have an account? ",
          action: 'Sign Up',
          onActionTap: () => Get.toNamed(AppRoutes.register),
        ).asSliver,
        SizedBox(height: 24.h).asSliver,
        const AuthBottomLinks().asSliver,
        SizedBox(height: 80.h).asSliver,
      ],
    );
  }

  Widget _buildFormCard() {
    return CustomContainer(
      radiusAll: 20.r,
      bordersColor: AppColors.divider.withValues(alpha: 0.5),
      color: AppColors.white,
      paddingAll: 24.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomText(
            text: 'Driver Login',
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: 'Enter your credentials to access your secure instance',
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 28.h),
          CustomTextField(
            controller: _authController.emailController,
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
          SizedBox(height: 08.h),
          _buildPasswordField(),
          SizedBox(height: 3.h),
          AuthRememberMeRow(
            value: _rememberMe,
            onChanged: (value) {
              setState(() => _rememberMe = value ?? false);
            },
          ),
          SizedBox(height: 24.h),
          Obx(
            () => CustomButton(
              label: 'Sign In →',
              isLoading: _authController.isLoading.value,
              onPressed: () {
                _authController.signIn();
              },
              backgroundColor: AppColors.primary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 24.h),
          Divider(color: AppColors.divider, thickness: 0.5),
          SizedBox(height: 24.h),
          CustomText(
            text:
                'Authorized personnel only. Access monitored by ASMAN security.',
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomText(
                text: 'Password',
                textAlign: TextAlign.start,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            CustomText(
              text: 'Forgot password?',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
              onTap: () {
                Get.toNamed(AppRoutes.forgot);
              },
            ),
          ],
        ),
        SizedBox(height: 6.h),
        CustomTextField(
          controller: _authController.passwordController,
          hintText: 'Enter you password',
          isPassword: true,
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: AppColors.textSecondary,
            size: 20.r,
          ),
        ),
      ],
    );
  }
}
