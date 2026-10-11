import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_task/features/notifications/presentation/notifications_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_task/core/helpers/floatingSuccessbar.dart';
import 'package:flutter_task/core/helpers/floatingErrorBar.dart';
import 'package:flutter_task/features/notifications/presentation/controller/notifications_controller.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/core/services/location_service.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h),
                    _buildHelpSection(),
                    SizedBox(height: 45.h),
                    const Center(child: AnimatedSOSButton()),
                    SizedBox(height: 50.h),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 100.h),
            child: _buildFooter(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    ProfileController profileController;
    try {
      profileController = Get.find<ProfileController>();
    } catch (_) {
      profileController = Get.put(ProfileController());
    }

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 70.h,
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
      title: Obx(() {
        final profile = profileController.driverProfile.value?.profile;
        final name = profile?.name ?? 'N/A';
        final avatarUrl = profile?.avatarUrl;

        return Row(
          children: [
            PresignedNetworkImage(
              height: 44.r,
              width: 44.r,
              boxShape: BoxShape.circle,
              imageUrl: avatarUrl?.isNotEmpty == true ? avatarUrl : null,
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Welcome back',
                  fontSize: 16.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 3),
                CustomText(
                  text: name,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF38BDF8),
                ),
              ],
            ),
          ],
        );
      }),
      actions: [
        Obx(() {
          final notificationsController = Get.find<NotificationsController>();
          final unreadCount = notificationsController.unreadCount.value;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(right: 16.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDFE3E7), width: 1),
                ),
                child: IconButton(
                  onPressed: () async {
                    await Get.to(() => const NotificationsScreen());
                    await notificationsController.fetchNotifications(
                      isBackground: true,
                    );
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/notification-bing.svg',
                    width: 24.r,
                    height: 24.r,
                    colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
                  ),
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 12.h,
                  right: 20.w,
                  child: Container(
                    padding: EdgeInsets.all(2.r),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16.r,
                      minHeight: 16.r,
                    ),
                    child: Center(
                      child: Text(
                        '$unreadCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildHelpSection() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: 'Need Help?',
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
              SizedBox(height: 8.h),
              CustomText(
                text: 'Press and hold the SOS button to share your live location with your support team.',
                fontSize: 14.sp,
                color: const Color(0xFF475569),
                textHeight: 1.5,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: Image.asset(
            'assets/images/homescreenImg.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOverlapAvatar(0),
            _buildOverlapAvatar(1),
            _buildOverlapAvatar(2),
          ],
        ),
        SizedBox(height: 12.h),
        CustomText(
          text: 'Your SOS will be sent to Admin',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E293B),
        ),
      ],
    );
  }

  Widget _buildOverlapAvatar(int index) {
    return Transform.translate(
      offset: Offset(index * -16.0.w, 0),
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFEDD5), // Orange 100
          border: Border.all(color: const Color(0xFF1E293B), width: 1.5), // Dark border
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.star_border_rounded, // Approximate star icon
          color: const Color(0xFFF97316), // Orange 500
          size: 24.r,
        ),
      ),
    );
  }
}

class AnimatedSOSButton extends StatefulWidget {
  const AnimatedSOSButton({super.key});

  @override
  State<AnimatedSOSButton> createState() => _AnimatedSOSButtonState();
}

class _AnimatedSOSButtonState extends State<AnimatedSOSButton> with TickerProviderStateMixin {
  bool _isSending = false;
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _handleSendSOS() async {
    setState(() {
      _isSending = true;
    });
    _rippleController.repeat();

    try {
      // 1. Fetch current GPS coordinates (permission was requested at login)
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();

      if (position == null) {
        // One more chance if the user denied at login.
        final granted = await locationService.ensurePermission();
        if (!granted) {
          if (mounted) {
            _rippleController.stop();
            _rippleController.reset();
            setState(() {
              _isSending = false;
            });
            FloatingErrorBar.show(
              context,
              message:
                  'Unable to retrieve location. Please enable GPS and allow location permissions.',
            );
          }
          return;
        }
      }

      final resolvedPosition =
          position ?? await locationService.getCurrentLocation();

      if (resolvedPosition == null) {
        if (mounted) {
          _rippleController.stop();
          _rippleController.reset();
          setState(() {
            _isSending = false;
          });
          FloatingErrorBar.show(
            context,
            message:
                'Unable to retrieve location. Please enable GPS and allow location permissions.',
          );
        }
        return;
      }

      // 2. Call the POST SOS trigger endpoint
      final apiService = Get.find<ApiService>();
      final response = await apiService.post(
        ApiConstants.sosTrigger,
        data: {
          "lat": resolvedPosition.latitude,
          "lon": resolvedPosition.longitude,
          "message": "Need help",
        },
      );

      if (mounted) {
        _rippleController.stop();
        _rippleController.reset();
        setState(() {
          _isSending = false;
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          FloatingSuccessBar.show(context, message: 'Your SOS alert has been sent.',);
        } else {
          final errMsg = response.data?['message'] ?? 'Failed to send SOS alert.';
          FloatingErrorBar.show(context, message: errMsg,);
        }
      }
    } catch (e) {
      if (mounted) {
        _rippleController.stop();
        _rippleController.reset();
        setState(() {
          _isSending = false;
        });
        FloatingErrorBar.show(context, message: 'An error occurred while sending SOS: $e',);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _isSending ? null : _handleSendSOS,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 250.r,
        height: 250.r,
        child: AnimatedBuilder(
          animation: _rippleController,
          builder: (context, child) {
            // Calculate ripple scales. When not sending, they are 1.0.
            // When sending, they pulsate outwards and fade out.
            double scale1 = _isSending ? 1.0 + (_rippleController.value * 0.2) : 1.0;
            double scale2 = _isSending ? 1.0 + (_rippleController.value * 0.1) : 1.0;
            double opacity1 = _isSending ? (1.0 - _rippleController.value) * 0.15 : 0.15;
            double opacity2 = _isSending ? (1.0 - _rippleController.value) * 0.2 : 0.2;

            return Center(
              child: Transform.scale(
                scale: scale1,
                child: Container(
                  width: 250.r,
                  height: 250.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF94A3B8).withValues(alpha: opacity1),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: scale2,
                      child: Container(
                        width: 200.r,
                        height: 200.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF94A3B8).withValues(alpha: opacity2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 160.r,
                            height: 160.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFCA5A5), Color(0xFFEF4444)], // Light Red to Red
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isSending
                                  ? CustomText(
                                      text: 'Sending...',
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CustomText(
                                          text: 'SOS',
                                          fontSize: 42.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.white,
                                        ),
                                        SizedBox(height: 4.h),
                                        CustomText(
                                          text: 'Press & hold for 3s',
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.white,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

