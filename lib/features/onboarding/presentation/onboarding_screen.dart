import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/core/utils/assets.gen.dart';
import 'package:flutter_task/features/onboarding/presentation/widgets/onboarding_feature_item.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: CustomSliverAppBar(
        expandedHeight: 540.h,
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.images.logo.image(height: 32.r, width: 32.r),
            CustomText(
              left: 6.w,
              text: 'asman'.toUpperCase(),
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
        flexiblePaddingTop: 20.h,
        flexibleChild: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomContainer(
              color: AppColors.white.withValues(alpha: 0.02),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.15),
                  offset: Offset(0, 25),
                  blurRadius: 50,
                ),
              ],
              radiusAll: 40.r,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40.r),
                child: Assets.images.onboarding.image(),
              ),
            ),

            CustomText(
              top: 32.h,
              text: 'Protection Beyond the Road.',
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 14.h),
            CustomText(
              left: 16.w,
              right: 16.w,
              text:
                  'Secure your journey with elite legal support and precision '
                  'logistics monitoring. Designed for those who demand'
                  ' absolute certainty.',
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
      bodyList: [
        Column(
          children: [
            SizedBox(height: 24.h),
            const OnboardingFeatureItem(
              icon: Icons.gavel_rounded,
              title: 'Elite Legal Network',
              description:
                  'Immediate access to specialized legal counsel, ensuring your '
                  'rights are protected across all jurisdictions.',
            ),
            const OnboardingFeatureItem(
              iconColor: AppColors.secondary,
              icon: Icons.route_rounded,
              title: 'Secure Route Mapping',
              description:
                  'Predictive risk assessment and dynamic route optimization '
                  'powered by real-time intelligence data.',
            ),
            const OnboardingFeatureItem(
              iconColor: AppColors.error,
              icon: Icons.support_agent_rounded,
              title: '24/7 Crisis Response',
              description:
                  'Round-the-clock monitoring and instant emergency dispatch for'
                  ' any logistical or safety incident.',
            ),
            SizedBox(height: 66.h),
            CustomContainer(
              radiusAll: 32.r,
              paddingAll: 44.r,
              width: double.infinity,
              color: AppColors.primary,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: 'Ready to secure your fleet?',
                    fontSize: 16.sp,
                    color: AppColors.white.withValues(alpha: 0.4),
                  ),
                  SizedBox(height: 18.h),
                  CustomButton(
                    label: 'Get Started →',
                    onPressed: () => Get.offAllNamed(AppRoutes.login),
                    backgroundColor: AppColors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ],
        ).asSliverWithPadding(horizontal: 24.w),
        SizedBox(height: 80.h).asSliver,
      ],
    );
  }
}
