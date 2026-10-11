import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/core/utils/assets.gen.dart';
import 'package:flutter_task/features/auth/presentation/widgets/auth_account_link_text.dart';
import 'package:flutter_task/features/auth/presentation/widgets/auth_brand_title.dart';
import 'package:flutter_task/features/auth/presentation/widgets/auth_checkbox_row.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _acceptTerms = false;
  final _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: CustomSliverAppBar(
        expandedHeight: 400.h,
        titleWidget: const AuthBrandTitle(),
        flexiblePaddingTop: 10.h,
        flexibleChild: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Assets.images.register.image(
            width: double.infinity,
            fit: BoxFit.cover,
            height: 320.h,
          ),
        ),
      ),
      bodyList: [
        CustomText(
          left: 16.w,
          textAlign: TextAlign.start,
          text: 'Secure Registration',
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
        ).asSliver,
        SizedBox(height: 8.h).asSliver,
        CustomText(
          left: 16.w,
          right: 16.w,
          textAlign: TextAlign.start,
          text:
          'Initialize your encrypted identity within the ASMAN secure ecosystem.',
          color: AppColors.textSecondary,
        ).asSliver,
        SizedBox(height: 28.h).asSliver,
        _buildFormCard().asSliverWithPadding(horizontal: 16.w),
        SizedBox(height: 32.h).asSliver,
        AuthAccountLinkText(
          prefix: 'Already have an account? ',
          action: 'Sign In',
          onActionTap: () => Get.back(canPop: true),
        ).asSliver,
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _authController.nameController,
              labelText: 'Full Name',
              hintText: 'e.g. Julian Voss',
              keyboardType: TextInputType.name,
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color: AppColors.textSecondary,
                size: 20.r,
              ),
            ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: _authController.emailController,
            labelText: 'Email Address',
            hintText: 'name@agency.gov',
            isEmail: true,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: AppColors.textSecondary,
              size: 16.r,
            ),
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: _authController.passwordController,
            labelText: 'Password',
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
            controller: _authController.confirmPasswordController,
            labelText: 'Confirm Password',
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
            controller: _authController.vinController,
            labelText: 'VIN Number',
            hintText: 'e.g. 1H3CM62...',
            keyboardType: TextInputType.text,
            prefixIcon: Icon(
              Icons.directions_car_outlined,
              color: AppColors.textSecondary,
              size: 20.r,
            ),
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: _authController.licenseController,
            labelText: 'License Plate',
            hintText: 'e.g. ASMAN-PRM',
            prefixIcon: Icon(
              Icons.credit_card_outlined,
              color: AppColors.textSecondary,
              size: 20.r,
            ),
          ),
          SizedBox(height: 20.h),
          _buildTermsRow(),
          SizedBox(height: 24.h),
          Obx(
            () => CustomButton(
              label: 'Create Account →',
              isLoading: _authController.isLoading.value,
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  if (!_acceptTerms) {
                    _authController.showSnackbar(
                      'Terms Required',
                      'Please acknowledge the Terms of Service and Privacy Protocol.',
                      isError: true,
                    );
                    return;
                  }
                  _authController.register();
                }
              },
              backgroundColor: AppColors.primary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildTermsRow() {
    return AuthCheckboxRow(
      value: _acceptTerms,
      onChanged: (value) => setState(() => _acceptTerms = value ?? false),
      label: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
          children: [
            const TextSpan(text: 'I acknowledge the '),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
              recognizer: TapGestureRecognizer()..onTap = () {},
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Protocol',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
              recognizer: TapGestureRecognizer()..onTap = () {},
            ),
          ],
        ),
      ),
    );
  }
}
