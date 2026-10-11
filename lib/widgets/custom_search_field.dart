import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({
    super.key,
    this.searchController,
    this.autoFocus = false,
    this.hintText,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
  });

  final TextEditingController? searchController;
  final String? hintText;
  final bool readOnly;
  final bool autoFocus;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: AppColors.textSecondary,
          ),
        ),
        child: SizedBox(
          height: 44.h,
          child: TextField(
            keyboardType: TextInputType.webSearch,
            onTap: onTap,
            readOnly: readOnly,
            autofocus: autoFocus,
            controller: searchController,
            onChanged: onChanged,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            decoration: InputDecoration(
              hintText: hintText ?? 'Search here . . .',
              hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              prefixIcon: Icon(
                Icons.search,
                size: 20.r,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.only(right: 16.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
