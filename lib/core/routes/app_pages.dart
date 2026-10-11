import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/features/auth/presentation/controller/auth_controller.dart';
import 'package:flutter_task/features/auth/presentation/screens/forgot_screen.dart';
import 'package:flutter_task/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_task/features/auth/presentation/screens/otp_screen.dart';
import 'package:flutter_task/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_task/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:flutter_task/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:flutter_task/features/bottom_nav_bar/presentation/main_bottom_nav_bar.dart';
import 'package:flutter_task/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter_task/features/splash/presentation/controllers/splash_controller.dart';
import 'package:flutter_task/features/splash/presentation/splash_screen.dart';
import 'package:flutter_task/features/notifications/presentation/controller/notifications_controller.dart';
import 'package:get/get.dart';

abstract class AppPages {
  AppPages._();

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgot,
      page: () => const ForgotScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.mainBottomNav,
      page: () => const MainBottomNavBar(),
      binding: MainBottomNavBinding(),
    ),
  ];
}

class MainBottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<BottomNavBarController>(BottomNavBarController(), permanent: true);
    Get.put<NotificationsController>(NotificationsController(), permanent: true);
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController(), permanent: true);
  }
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
