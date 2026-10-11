import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';

class AppThemeData {

  static final ThemeData themeData = ThemeData(
    scaffoldBackgroundColor: AppColors.background,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 20.sp,
        fontFamily: 'Montserrat',
      ),
      scrolledUnderElevation: 0,
      foregroundColor: Colors.white,
      elevation: 0,

      // Status Bar Color
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColors.background,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),

    fontFamily: 'Montserrat',
  );
}
