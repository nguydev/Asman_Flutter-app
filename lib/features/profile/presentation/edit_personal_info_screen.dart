import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter_task/core/services/file_service.dart';
import 'package:flutter_task/core/helpers/floatingErrorBar.dart';
import 'package:flutter_task/core/helpers/floatingSuccessbar.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class EditPersonalInfoScreen extends StatefulWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  final ProfileController _profileController = Get.find<ProfileController>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');

  @override
  void initState() {
    super.initState();
    final profileData = _profileController.driverProfile.value;
    
    _nameController.text = profileData?.profile?.name ?? '';
    _emailController.text = profileData?.email ?? '';
    _addressController.text = profileData?.profile?.address ?? '';

    // Leave the national-number field empty unless we have a real E.164 value.
    // Default country (US / +1) in the UI must not be treated as a phone.
    final existingPhone = (profileData?.phone ?? '').trim();
    if (RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(existingPhone)) {
      _loadPhoneNumber(existingPhone);
    }
  }

  Future<void> _loadPhoneNumber(String phoneString) async {
    if (phoneString.isNotEmpty) {
      var formatted = phoneString.trim();
      if (!formatted.startsWith('+')) {
        if (formatted.startsWith('0')) {
          formatted = '+880${formatted.substring(1)}';
        } else if (formatted.startsWith('880')) {
          formatted = '+$formatted';
        } else {
          formatted = '+$formatted';
        }
      }

      try {
        PhoneNumber parsed = await PhoneNumber.getRegionInfoFromPhoneNumber(formatted);
        setState(() {
          _phoneNumber = parsed;
        });
      } catch (e) {
        debugPrint('Error parsing phone number region info: $e');
        try {
          PhoneNumber fallback = await PhoneNumber.getRegionInfoFromPhoneNumber(formatted, 'BD');
          setState(() {
            _phoneNumber = fallback;
          });
        } catch (_) {}
      }
    }
  }

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: CustomText(
          text: 'Edit Personal Info',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20.r),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  PresignedNetworkImage(
                    imageUrl: _profileController.driverProfile.value?.profile?.avatarUrl,
                    height: 100.r,
                    width: 100.r,
                    boxShape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondary, width: 2),
                    imageFile: _imageFile,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.white,
                        size: 16.r,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            CustomContainer(
              color: AppColors.white,
              radiusAll: 24,
              paddingAll: 24.r,
              elevation: true,
              border: Border.all(color: const Color(0xFFDFE3E7), width: 1),
              elevationColor: AppColors.black.withValues(alpha: 0.03),
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    filColor: AppColors.white,
                    borderRadio: 12.r,
                  ),
                  SizedBox(height: 8.h),
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    filColor: const Color(0xFFF1F5F9), // Light gray background to show it's disabled
                    borderRadio: 12.r,
                    readOnly: true,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      CustomText(
                        text: 'Phone Number',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        bottom: 4.h,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  IgnorePointer(
                    ignoring: _profileController.isLoading.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFDFE3E7), width: 1),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 12.w),
                        child: InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            _phoneNumber = number;
                          },
                          selectorConfig: const SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            useEmoji: true,
                          ),
                          ignoreBlank: true,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          initialValue: _phoneNumber,
                          textFieldController: _phoneController,
                          formatInput: false,
                          spaceBetweenSelectorAndTextField: 0,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          inputDecoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                              left: 0,
                              right: 16.w,
                              top: 16.h,
                              bottom: 16.h,
                            ),
                            fillColor: Colors.transparent,
                            filled: true,
                            hintText: 'Enter your phone number',
                            hintStyle: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            border: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextField(
                    controller: _addressController,
                    labelText: 'Primary Address',
                    hintText: 'Enter your address',
                    filColor: AppColors.white,
                    borderRadio: 12.r,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Obx(() {
              return CustomButton(
                onPressed: _profileController.isLoading.value ? null : () async {
                  String? avatarValue;

                  if (_imageFile != null) {
                    try {
                      _profileController.isLoading.value = true;

                      final fileService = Get.find<FileService>();
                      avatarValue =
                          await fileService.uploadPublicAsset(_imageFile!);

                      if (avatarValue == null) {
                        _profileController.isLoading.value = false;
                        if (context.mounted) {
                          FloatingErrorBar.show(
                            context,
                            message:
                                'Failed to upload profile picture. Ensure storage public URL is configured.',
                          );
                        }
                        return;
                      }
                    } catch (e) {
                      _profileController.isLoading.value = false;
                      if (context.mounted) {
                        FloatingErrorBar.show(context, message: 'Error uploading profile picture: $e');
                      }
                      return;
                    }
                  } else {
                    avatarValue = _profileController.driverProfile.value?.profile?.avatarUrl;
                  }
                  
                  // Country selector always has a dial code (e.g. +1). Only send
                  // phone when the user typed a national number in the field.
                  final nationalDigits = _phoneController.text
                      .replaceAll(RegExp(r'\D'), '');
                  final phoneRegex = RegExp(r'^\+[1-9]\d{7,14}$');
                  String? phoneToSend;
                  if (nationalDigits.isNotEmpty) {
                    final candidate =
                        (_phoneNumber.phoneNumber ?? '').trim();
                    if (!phoneRegex.hasMatch(candidate)) {
                      if (context.mounted) {
                        FloatingErrorBar.show(
                          context,
                          message:
                              'Enter a valid phone with country code (e.g. +15551234567).',
                        );
                      }
                      _profileController.isLoading.value = false;
                      return;
                    }
                    phoneToSend = candidate;
                  }

                  final street = _addressController.text.trim();
                  final Map<String, dynamic> data = {
                    "name": _nameController.text.trim(),
                    if (phoneToSend != null) "phone": phoneToSend,
                    if (avatarValue != null && avatarValue.isNotEmpty)
                      "avatarUrl": avatarValue,
                    if (street.isNotEmpty)
                      "address": {
                        "street": street,
                        "city": "",
                        "state": "",
                        "zipCode": "",
                      },
                  };
  
                  final success = await _profileController.updateProfile(data);
                  if (success) {
                    Get.back();
                    if (context.mounted) {
                      FloatingSuccessBar.show(context, message: 'Profile updated successfully');
                    }
                  } else {
                    if (context.mounted) {
                      FloatingErrorBar.show(context, message: _profileController.errorMessage.value);
                    }
                  }
                },
                label: 'Save Changes',
                backgroundColor: const Color(0xFF0f172a),
                foregroundColor: AppColors.white,
                radius: 8.r,
                height: 52.h,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                child: _profileController.isLoading.value
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : null,
              );
            }),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
