import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/features/profile/presentation/widgets/contact_card.dart';
import 'package:flutter_task/features/profile/presentation/add_sos_screen.dart';
import 'package:flutter_task/features/profile/presentation/controllers/sos_controller.dart';
import 'package:flutter_task/core/helpers/floatingErrorBar.dart';
import 'package:flutter_task/core/helpers/floatingSuccessbar.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';

import '../data/models/sos_contact_model.dart';

class SetupSosScreen extends StatefulWidget {
  const SetupSosScreen({super.key});

  @override
  State<SetupSosScreen> createState() => _SetupSosScreenState();
}

class _SetupSosScreenState extends State<SetupSosScreen> {
  late final SosController _sosController;

  @override
  void initState() {
    super.initState();
    try {
      _sosController = Get.find<SosController>();
    } catch (_) {
      _sosController = Get.put(SosController());
    }
  }

  Future<void> _confirmDelete(BuildContext context, SosContact contact) async {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete SOS Contact'),
        content: Text('Are you sure you want to delete ${contact.name} from your emergency network?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await _sosController.deleteSosContact(contact.id);
              if (success) {
                if (context.mounted) {
                  FloatingSuccessBar.show(context, message: 'SOS Contact deleted successfully');
                }
              } else {
                if (context.mounted) {
                  FloatingErrorBar.show(context, message: _sosController.errorMessage.value);
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: CustomText(
          text: 'Setup SOS',
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
        actions: [
          GestureDetector(
            onTap: () => Get.to(() => const AddSosScreen()),
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: const Color(0xFFDFE3E7), width: 0.5),
              ),
              child: Icon(Icons.add, color: AppColors.textPrimary, size: 20.r),
            ),
          ),
        ],
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
        onRefresh: () => _sosController.fetchSosContacts(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: 'Emergency Network',
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 8.h),
              CustomText(
                text: 'Update your emergency contacts to notify in case of SOS triggers.',
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                textHeight: 1.5,
              ),
              SizedBox(height: 24.h),
              
              Obx(() {
                if (_sosController.isFetching.value && _sosController.contacts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CupertinoActivityIndicator(),
                    ),
                  );
                }

                if (_sosController.contacts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 80.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.contact_phone_outlined,
                            size: 64.r,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          SizedBox(height: 16.h),
                          CustomText(
                            text: 'No SOS contacts added yet.',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 8.h),
                          CustomText(
                            text: 'Tap the "+" button in the app bar to add one.',
                            fontSize: 13.sp,
                            color: AppColors.textSecondary.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sosController.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _sosController.contacts[index];
                    return ContactCard(
                      name: contact.name,
                      subtitle: '${contact.relation} • ${contact.phone}',
                      imageUrl: contact.avatar.isNotEmpty ? contact.avatar : null,
                      onDelete: () => _confirmDelete(context, contact),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
