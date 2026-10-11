import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/routes/app_pages.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/themes/app_theme_data.dart';
import 'package:flutter_task/widgets/keyboard_dismiss_on_tap.dart';
import 'package:get/get.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) => GetMaterialApp(
        theme: AppThemeData.themeData,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.initial,
        getPages: AppPages.routes,
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 200),
        builder: (context, child) => KeyboardDismissOnTap(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

}
