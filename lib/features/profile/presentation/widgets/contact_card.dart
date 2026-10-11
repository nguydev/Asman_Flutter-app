import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContactCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback? onDelete;

  const ContactCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.imageUrl,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      radiusAll: 16.r,
      paddingAll: 12.r,
      marginBottom: 16.h,
      border: Border.all(color: const Color(0xFFDFE3E7), width: 1),
      child: Stack(
        children: [
          Row(
            children: [
              PresignedNetworkImage(
                imageUrl: imageUrl,
                height: 52.r,
                width: 52.r,
                boxShape: BoxShape.circle,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: name,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      text: subtitle,
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              if (onDelete != null) SizedBox(width: 36.w),
            ],
          ),
          if (onDelete != null)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
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
                  child: SvgPicture.asset(
                    'assets/icons/deleteIcon.svg',
                    width: 20.r,
                    height: 20.r,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
