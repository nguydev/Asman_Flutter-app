import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/features/bottom_nav_bar/data/models/nav_item_model.dart';
import 'package:flutter_task/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:flutter_task/features/bottom_nav_bar/presentation/widgets/nav_item_widget.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BottomNavBarController>();
    final itemCount = NavItemModel.userNavItems.length;

    return CustomContainer(
      color: AppColors.white,
      border: const Border(
        top: BorderSide(
          color: Color(0xFFDFE3E7),
          width: 1,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.03),
          offset: const Offset(0, -4),
          blurRadius: 20,
        )
      ],
      topRightRadius: 32.r,
      topLeftRadius: 32.r,
      child: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / itemCount;

          void handlePointer(Offset localPosition) {
            final index = (localPosition.dx / itemWidth)
                .floor()
                .clamp(0, itemCount - 1);
            if (controller.selectedIndex != index) {
              HapticFeedback.selectionClick();
              controller.onChange(index);
            }
          }

          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) => handlePointer(event.localPosition),
            onPointerMove: (event) => handlePointer(event.localPosition),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  itemCount,
                  (index) {
                    final navItem = NavItemModel.userNavItems[index];
                    return BottomNavItem(
                      index: index,
                      navItem: navItem,
                    );
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}