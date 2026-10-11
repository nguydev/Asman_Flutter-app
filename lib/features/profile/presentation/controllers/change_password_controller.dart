import 'package:flutter/foundation.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      debugPrint('ChangePasswordController: starting changePassword...');
      isLoading.value = true;
      errorMessage.value = '';

      debugPrint('ChangePasswordController: sending PATCH request to change password...');
      final response = await _apiService.patch(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      debugPrint('ChangePasswordController: response received. Status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        errorMessage.value = 'Failed to change password. Status: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      debugPrint('ChangePasswordController: error caught: $e');
      if (e is AppException) {
        errorMessage.value = e.message;
      } else {
        errorMessage.value = e.toString();
      }
      return false;
    } finally {
      debugPrint('ChangePasswordController: finally block. Setting isLoading to false.');
      isLoading.value = false;
    }
  }
}
