import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/core/utils/fonts.gen.dart';
import 'package:flutter_task/features/bottom_nav_bar/data/models/nav_item_model.dart';
import 'package:flutter_task/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';

class BottomNavItem extends StatefulWidget {
  final NavItemModel navItem;
  final int index;

  const BottomNavItem({super.key, required this.navItem, required this.index});

  @override
  State<BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<BottomNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool _wasSelected = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.85,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.85,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomNavBarController>(
      builder: (controller) {
        final isSelected = controller.selectedIndex == widget.index;

        if (isSelected && !_wasSelected) {
          _controller.forward(from: 0);
        }
        _wasSelected = isSelected;

        return IgnorePointer(
          child: ScaleTransition(
            scale: _scale,
            child: CustomContainer(
              width: 65.w,
              height: 54.h,
              radiusAll: 12.r,
              color: isSelected
                  ? const Color(0xFF38BDF8).withValues(alpha: 0.1)
                  : Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: SvgPicture.asset(
                      widget.navItem.icon,
                      colorFilter: isSelected
                          ? const ColorFilter.mode(Color(0xFF38BDF8), BlendMode.srcIn)
                          : null,
                      width: 18.w,
                      height: 18.h,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontFamily: FontFamily.inter,
                      fontSize: 12.sp,
                      color: isSelected
                          ? const Color(0xFF38BDF8)
                          : AppColors.textSecondary,
                    ),
                    child: Text(widget.navItem.label ?? ''),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
