import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:flutter_task/features/notifications/presentation/widgets/notification_card.dart';
import 'package:flutter_task/features/notifications/presentation/controller/notifications_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasData = controller.notificationsList.isNotEmpty;
      controller.fetchNotifications(isBackground: hasData);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: CustomText(
          text: 'Notification',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.r, color: AppColors.textPrimary),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'New Notification',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.markAllAsRead();
                    },
                    child: CustomText(
                      text: 'Mark as read',
                      fontSize: 14.sp,
                      color: const Color(0xFF38BDF8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              Obx(() {
                debugPrint('🔔 Obx rebuild: isLoading=${controller.isLoading.value}, listLength=${controller.notificationsList.length}');
                
                if (controller.isLoading.value && controller.notificationsList.isEmpty) {
                  return const CustomLoader(top: 40);
                }

                if (controller.notificationsList.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 80.h),
                    child: EmptyDataWidget(
                      message: 'No notifications found',
                      onRefresh: () => controller.fetchNotifications(),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.notificationsList.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Color(0xFFF1F5F9),
                    height: 1,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = controller.notificationsList[index];
                    
                    // Resolve icon dynamically
                    IconData icon = Icons.notifications_none_rounded;
                    Color iconColor = const Color(0xFF3B82F6);
                    Color iconBgColor = const Color(0xFFEFF6FF);

                    if (item.type.toUpperCase() == 'SOS' || item.title.toLowerCase().contains('sos')) {
                      icon = Icons.wifi_tethering;
                      iconColor = const Color(0xFFEAB308);
                      iconBgColor = const Color(0xFFFEF9C3);
                    } else if (item.type.toUpperCase() == 'DETENTION' || item.title.toLowerCase().contains('detention')) {
                      icon = Icons.access_time_rounded;
                      iconColor = const Color(0xFFEF4444);
                      iconBgColor = const Color(0xFFFEF2F2);
                    }

                    return NotificationCard(
                      icon: icon,
                      iconColor: iconColor,
                      iconBgColor: iconBgColor,
                      title: item.title,
                      description: item.message,
                      time: '${DateTime.now().difference(item.createdAt).inMinutes}m ago',
                      isUnread: !item.isRead,
                      onTap: () {
                        controller.markAsRead(item.id);
                      },
                    );
                  },
                );
              }),
              
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
