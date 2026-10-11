import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_task/features/profile/presentation/controllers/legal_controller.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final LegalController _legalController;

  @override
  void initState() {
    super.initState();
    try {
      _legalController = Get.find<LegalController>();
    } catch (_) {
      _legalController = Get.put(LegalController());
    }
    _legalController.fetchPrivacyPolicy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: CustomText(
          text: 'Privacy Policy',
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
      body: RefreshIndicator(
        onRefresh: () => _legalController.fetchPrivacyPolicy(),
        child: Obx(() {
          if (_legalController.isFetchingPrivacy.value) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

          final contentText = _legalController.privacyPolicyText.value;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: CustomContainer(
              width: double.infinity,
              color: AppColors.white,
              radiusAll: 12.r,
              paddingAll: 16.r,
              border: Border.all(color: const Color(0xFFDFE3E7), width: 1),
              child: contentText.isNotEmpty
                  ? _buildFormattedContent(contentText)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: '1. Information Collection',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(height: 8.h),
                        CustomText(
                          text:
                              'We collect information from you when you register on our app, place an order, subscribe to our newsletter, respond to a survey, or fill out a form. The data collected may include your name, email address, mailing address, phone number, or other personal details.',
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                          textHeight: 1.5,
                        ),
                        SizedBox(height: 24.h),
                        CustomText(
                          text: '2. Use of Information',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(height: 8.h),
                        CustomText(
                          text:
                              'Any of the information we collect from you may be used in one of the following ways: \n\n• To personalize your experience.\n• To improve our app.\n• To improve customer service.\n• To process transactions.\n• To send periodic emails.',
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                          textHeight: 1.5,
                        ),
                        SizedBox(height: 24.h),
                        CustomText(
                          text: '3. Data Security',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(height: 8.h),
                        CustomText(
                          text:
                              'We implement a variety of security measures to maintain the safety of your personal information when you place an order or enter, submit, or access your personal information.',
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                          textHeight: 1.5,
                        ),
                        SizedBox(height: 24.h),
                        CustomText(
                          text: '4. Third-Party Disclosure',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(height: 8.h),
                        CustomText(
                          text:
                              'We do not sell, trade, or otherwise transfer to outside parties your Personally Identifiable Information unless we provide users with advance notice. This does not include website hosting partners and other parties who assist us in operating our app, conducting our business, or serving our users.',
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                          textHeight: 1.5,
                        ),
                      ],
                    ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFormattedContent(String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(SizedBox(height: 8.h));
        continue;
      }

      if (trimmed.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
            child: CustomText(
              text: trimmed.substring(2),
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        );
      } else if (trimmed.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
            child: CustomText(
              text: trimmed.substring(3),
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        );
      } else if (trimmed.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
            child: CustomText(
              text: trimmed.substring(4),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: CustomText(
              text: trimmed,
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              textHeight: 1.5,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
