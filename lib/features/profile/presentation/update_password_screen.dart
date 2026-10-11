import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_task/features/profile/presentation/controllers/change_password_controller.dart';
import 'package:flutter_task/core/helpers/floatingErrorBar.dart';
import 'package:flutter_task/core/helpers/floatingSuccessbar.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final ChangePasswordController _changePasswordController;

  @override
  void initState() {
    super.initState();
    try {
      _changePasswordController = Get.find<ChangePasswordController>();
    } catch (_) {
      _changePasswordController = Get.put(ChangePasswordController());
    }
  }

  Future<void> _savePassword() async {
    debugPrint('UpdatePasswordScreen: _savePassword button tapped.');
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      FloatingErrorBar.show(context, message: 'Please enter your current password.');
      return;
    }
    if (newPassword.isEmpty) {
      FloatingErrorBar.show(context, message: 'Please enter your new password.');
      return;
    }
    if (confirmPassword.isEmpty) {
      FloatingErrorBar.show(context, message: 'Please confirm your new password.');
      return;
    }
    if (newPassword != confirmPassword) {
      FloatingErrorBar.show(context, message: 'New password and confirm password do not match.');
      return;
    }
    if (newPassword.length < 6) {
      FloatingErrorBar.show(context, message: 'Password must be at least 6 characters long.');
      return;
    }

    final success = await _changePasswordController.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    if (success) {
      if (mounted) {
        FloatingSuccessBar.show(context, message: 'Password changed successfully');
        Get.back();
      }
    } else {
      if (mounted) {
        FloatingErrorBar.show(context, message: _changePasswordController.errorMessage.value);
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const SizedBox.shrink(),
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20.r),
          onPressed: () => Get.back(),
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Color(0xFFDFE3E7),
            width: 1,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32.r),
            bottomRight: Radius.circular(32.r),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'Change Password',
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 12.h),
            CustomText(
              text: 'Update your password to keep your ASMAN account secure.',
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
            ),
            SizedBox(height: 32.h),
            CustomTextField(
              controller: _currentPasswordController,
              hintText: 'Current Password',
              isPassword: true,
              filColor: AppColors.white,
              borderRadio: 8.r,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _newPasswordController,
              hintText: 'New Password',
              isPassword: true,
              filColor: AppColors.white,
              borderRadio: 8.r,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _confirmPasswordController,
              hintText: 'Confirm New Password',
              isPassword: true,
              filColor: AppColors.white,
              borderRadio: 8.r,
            ),
            SizedBox(height: 24.h),
            Obx(() {
              final loading = _changePasswordController.isLoading.value;
              return CustomButton(
                onPressed: loading ? null : _savePassword,
                label: 'Save Password',
                backgroundColor: const Color(0xFF0f172a),
                foregroundColor: AppColors.white,
                radius: 8.r,
                height: 52.h,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                child: loading
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
