import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/core/helpers/floatingErrorBar.dart';
import 'package:flutter_task/core/helpers/floatingSuccessbar.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_task/features/profile/presentation/controllers/legal_controller.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  late final LegalController _legalController;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    try {
      _legalController = Get.find<LegalController>();
    } catch (_) {
      _legalController = Get.put(LegalController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      FloatingErrorBar.show(context, message: 'Please tell us your problem title');
      return;
    }
    if (description.isEmpty) {
      FloatingErrorBar.show(context, message: 'Please describe the problem details');
      return;
    }

    final success = await _legalController.submitHelpRequest(title, description);
    if (success) {
      if (mounted) {
        FloatingSuccessBar.show(context, message: 'Support request sent successfully');
        Get.back();
      }
    } else {
      if (mounted) {
        FloatingErrorBar.show(context, message: _legalController.errorMessage.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: CustomText(
          text: 'Help & Support',
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
        final loading = _legalController.isSubmittingSupport.value;
        return IgnorePointer(
          ignoring: loading,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              children: [
                CustomContainer(
                  color: AppColors.white,
                  radiusAll: 12.r,
                  paddingHorizontal: 16.w,
                  border: Border.all(color: const Color(0xFFDFE3E7), width: 1),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Tell us your problem...',
                      hintStyle: TextStyle(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                CustomContainer(
                  color: AppColors.white,
                  radiusAll: 12.r,
                  paddingAll: 16.r,
                  border: Border.all(color: const Color(0xFFDFE3E7), width: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 10,
                        decoration: InputDecoration(
                          hintText: 'e.g. My app is not working...',
                          hintStyle: TextStyle(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.insert_drive_file, color: const Color(0xFF64748B), size: 16.r),
                          SizedBox(width: 4.w),
                          CustomText(
                            text: '2/10',
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.w).copyWith(bottom: 32.h),
        child: Obx(() {
          final loading = _legalController.isSubmittingSupport.value;
          return CustomButton(
            onPressed: loading ? () {} : _sendRequest,
            label: 'Send',
            backgroundColor: const Color(0xFF0f172a),
            foregroundColor: AppColors.white,
            radius: 8.r,
            height: 52.h,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            suffixIcon: loading
                ? null
                : Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: Icon(Icons.send_outlined, color: AppColors.white, size: 20.r),
                  ),
            child: loading
                ? const CupertinoActivityIndicator(color: Colors.white)
                : null,
          );
        }),
      ),
    );
  }
}
