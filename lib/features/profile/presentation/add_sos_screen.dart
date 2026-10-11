import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/utils/app_colors.dart';
import 'package:flutter_task/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_task/features/profile/presentation/controllers/sos_controller.dart';
import 'package:flutter_task/core/helpers/floatingErrorBar.dart';
import 'package:flutter_task/core/helpers/floatingSuccessbar.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class AddSosScreen extends StatefulWidget {
  const AddSosScreen({super.key});

  @override
  State<AddSosScreen> createState() => _AddSosScreenState();
}

class _AddSosScreenState extends State<AddSosScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  late final SosController _sosController;

  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');

  @override
  void initState() {
    super.initState();
    try {
      _sosController = Get.find<SosController>();
    } catch (_) {
      _sosController = Get.put(SosController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    super.dispose();
  }

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

  Future<void> _saveContact() async {
    final name = _nameController.text.trim();
    final relation = _relationController.text.trim();
    var phone = _phoneNumber.phoneNumber ?? '';

    if (phone.isEmpty) {
      phone = _phoneController.text.trim();
      if (phone.isNotEmpty && !phone.startsWith('+')) {
        if (phone.startsWith('0')) {
          phone = '+880${phone.substring(1)}';
        } else if (phone.startsWith('880')) {
          phone = '+$phone';
        } else {
          // Default USA code (+1) as USA is the default flag
          phone = '+1$phone';
        }
      }
    }

    if (name.isEmpty) {
      FloatingErrorBar.show(context, message: 'Please enter a name');
      return;
    }
    if (phone.isEmpty) {
      FloatingErrorBar.show(context, message: 'Please enter a phone number');
      return;
    }
    if (relation.isEmpty) {
      FloatingErrorBar.show(context, message: 'Please enter a relation');
      return;
    }

    final success = await _sosController.addSosContact(
      name: name,
      phone: phone,
      relation: relation,
      imageFile: _imageFile,
    );

    if (success) {
      if (mounted) {
        FloatingSuccessBar.show(context, message: 'SOS Contact added successfully');
        Get.back();
      }
    } else {
      if (mounted) {
        FloatingErrorBar.show(context, message: _sosController.errorMessage.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: CustomText(
          text: 'Add SOS',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'Emergency Contact',
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: 'Add a trusted emergency contact to notify in case of SOS triggers.',
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              textHeight: 1.5,
            ),
            SizedBox(height: 24.h),

            // Profile Image Upload Picker
            Obx(() {
              final loading = _sosController.isLoading.value;
              return Center(
                child: GestureDetector(
                  onTap: loading ? null : _pickImage,
                  child: Stack(
                    children: [
                      PresignedNetworkImage(
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
              );
            }),
            SizedBox(height: 32.h),

            // Full name field
            CustomTextField(
              controller: _nameController,
              hintText: 'Full name',
              filColor: AppColors.white,
              borderRadio: 8.r,
            ),
            SizedBox(height: 16.h),

            // Phone Number field using intl_phone_number_input
            Obx(() {
              final loading = _sosController.isLoading.value;
              return IgnorePointer(
                ignoring: loading,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8.r),
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
                      ignoreBlank: false,
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
                        hintText: 'Phone Number',
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
                        errorStyle: TextStyle(fontSize: 12.h, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: 20.h),

            // Relation field
            CustomTextField(
              controller: _relationController,
              hintText: 'Relation',
              filColor: AppColors.white,
              borderRadio: 8.r,
            ),
            SizedBox(height: 24.h),

            // Save Button
            Obx(() {
              final loading = _sosController.isLoading.value;
              return CustomButton(
                onPressed: loading ? null : _saveContact,
                label: 'Save',
                backgroundColor: const Color(0xFF0f172a),
                foregroundColor: AppColors.white,
                radius: 8.r,
                height: 52.h,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                child: loading
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
