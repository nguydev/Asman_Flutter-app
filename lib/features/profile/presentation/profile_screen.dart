import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter_task/features/profile/presentation/documents_screen.dart';
import 'package:flutter_task/features/profile/presentation/help_support_screen.dart';
import 'package:flutter_task/features/profile/presentation/personal_info_screen.dart';
import 'package:flutter_task/features/profile/presentation/privacy_policy_screen.dart';
import 'package:flutter_task/features/profile/presentation/setup_sos_screen.dart';
import 'package:flutter_task/features/profile/presentation/update_password_screen.dart';
import 'package:flutter_task/features/profile/presentation/widgets/logout_confirm_dialog.dart';
import 'package:flutter_task/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:flutter_task/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:flutter_task/features/profile/presentation/widgets/profile_menu_section.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  ProfileController _resolveController() {
    if (Get.isRegistered<ProfileController>()) {
      return Get.find<ProfileController>();
    }
    return Get.put(ProfileController());
  }

  List<ProfileMenuItem> get _accountSettings => [
        ProfileMenuItem(
          iconPath: 'assets/icons/personalInfoIcon.svg',
          title: 'Personal Information',
          onTap: () => Get.to(() => const PersonalInfoScreen()),
        ),
        ProfileMenuItem(
          iconPath: 'assets/icons/passwordIcon.svg',
          title: 'Password & Security',
          onTap: () => Get.to(() => const UpdatePasswordScreen()),
        ),
        ProfileMenuItem(
          iconPath: 'assets/icons/sosIcon.svg',
          title: 'Setup SOS',
          onTap: () => Get.to(() => const SetupSosScreen()),
        ),
        ProfileMenuItem(
          iconPath: 'assets/icons/documents.svg',
          title: 'Documents',
          onTap: () => Get.to(() => const DocumentsScreen()),
        ),
      ];

  List<ProfileMenuItem> get _preferences => [
        ProfileMenuItem(
          iconPath: 'assets/icons/help&supportIcon.svg',
          title: 'Help & Support',
          onTap: () => Get.to(() => const HelpSupportScreen()),
        ),
        ProfileMenuItem(
          iconPath: 'assets/icons/privacyIcon.svg',
          title: 'Privacy Policy',
          onTap: () => Get.to(() => const PrivacyPolicyScreen()),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final profileController = _resolveController();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: CustomText(
          text: 'Profile',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFDFE3E7), width: 1),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32.r),
            bottomRight: Radius.circular(32.r),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileHeaderCard(controller: profileController),
            ProfileMenuSection(
              title: 'Account',
              items: _accountSettings,
            ),
            ProfileMenuSection(
              title: 'Support',
              items: _preferences,
            ),
            SizedBox(height: 4.h),
            TextButton(
              onPressed: LogoutConfirmDialog.show,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: CustomText(
                text: 'Log Out',
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 20.h),
            Center(
              child: CustomText(
                text: 'Version 1.0.0 (1)',
                fontSize: 12.sp,
                color: AppColors.textHint,
              ),
            ),
            SizedBox(height: 4.h),
            Center(
              child: CustomText(
                text: '© 2026 ASMAN',
                fontSize: 12.sp,
                color: AppColors.textHint,
              ),
            ),
            SizedBox(height: 70.h),
          ],
        ),
      ),
    );
  }
}
