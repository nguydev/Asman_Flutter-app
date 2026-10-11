import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_task/features/profile/presentation/edit_personal_info_screen.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            fontSize: 13.sp,
            color: const Color(0xFF9ca3af),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: CustomText(
              text: value,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1f2937),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return CustomContainer(
      color: AppColors.white,
      radiusAll: 12.r,
      marginBottom: 20.h,
      border: Border.all(color: const Color(0xFFDFE3E7), width: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomContainer(
            color: const Color(0xFFF0F8FF), // Light blue tint
            radiusAll: 0,
            topLeftRadius: 12.r,
            topRightRadius: 12.r,
            width: double.infinity,
            paddingAll: 14.r,
            child: CustomText(
              text: title,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Divider(color: const Color(0xFFDFE3E7), height: 1, indent: 0, endIndent: 0),
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Divider(color: const Color(0xFFDFE3E7), height: 1, indent: 0, endIndent: 0),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: CustomText(
          text: 'Personal Information',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
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
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(child: CupertinoActivityIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          children: [
            // Profile Image
            Center(
              child: Obx(() {
                final avatarUrl = profileController.driverProfile.value?.profile?.avatarUrl;
                return PresignedNetworkImage(
                  imageUrl: avatarUrl?.isNotEmpty == true ? avatarUrl : null,
                  height: 100.r,
                  width: 100.r,
                  boxShape: BoxShape.circle,
                );
              }),
            ),
            SizedBox(height: 24.h),

            // Personal Information Card
            Obx(() {
              final profileData = profileController.driverProfile.value;
              final name = profileData?.profile?.name ?? 'N/A';
              final email = profileData?.email ?? 'N/A';
              final phone = profileData?.phone ?? 'N/A';
              final address = profileData?.profile?.address ?? 'N/A';

              return _buildSection(
                title: 'Personal Information',
                items: [
                  _buildInfoRow('Full Name:', name),
                  _buildInfoRow('Email:', email),
                  _buildInfoRow('Phone Number:', phone),
                  _buildInfoRow('Address:', address),
                ],
              );
            }),

            // Vehicle Fleet Card
            Obx(() {
              final driverData = profileController.driverProfile.value?.driver;
              final vinNumber = driverData?.vinNumber ?? 'N/A';
              final licensePlate = driverData?.licensePlate ?? 'N/A';

              return _buildSection(
                title: 'Vehicle Fleet',
                items: [
                  _buildInfoRow('VIN Number:', vinNumber),
                  _buildInfoRow('License Plate:', licensePlate),
                ],
              );
            }),

            SizedBox(height: 16.h),

            // Edit Button
            CustomButton(
              onPressed: () {
                Get.to(() => const EditPersonalInfoScreen());
              },
              label: 'Edit',
              backgroundColor: const Color(0xFF0f172a),
              foregroundColor: AppColors.white,
              radius: 8.r,
              height: 52.h,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            
            SizedBox(height: 32.h),
          ],
        ),
      );
    }),
    );
  }
}
