import 'package:flutter/foundation.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/features/profile/data/models/driver_profile_model.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var driverProfile = Rxn<DriverProfileData>();

  @override
  void onInit() {
    super.onInit();
    fetchDriverProfile();
  }

  Future<void> fetchDriverProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      dynamic response;
      try {
        debugPrint('Fetching profile from: ${ApiConstants.getProfile}');
        response = await _apiService.get(
          ApiConstants.getProfile,
          queryParameters: {
            't': DateTime.now().millisecondsSinceEpoch.toString(),
          },
        );
      } catch (e) {
        debugPrint('Failed to fetch from ${ApiConstants.getProfile}: $e. Trying fallback: ${ApiConstants.userProfile}');
        response = await _apiService.get(
          ApiConstants.userProfile,
          queryParameters: {
            't': DateTime.now().millisecondsSinceEpoch.toString(),
          },
        );
      }

      debugPrint('Profile API response status: ${response.statusCode}');
      debugPrint('Profile API response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('success') && data['success'] != null) {
            final profileResponse = DriverProfileResponse.fromJson(data);
            if (profileResponse.success == true) {
              driverProfile.value = profileResponse.data;
            } else {
              errorMessage.value = profileResponse.message ?? 'Failed to fetch profile';
            }
          } else {
            // Parse unwrapped direct user model response
            driverProfile.value = DriverProfileData.fromJson(data);
          }
        } else {
          errorMessage.value = 'Invalid profile response format';
        }
      } else {
        errorMessage.value = 'Failed to fetch profile. Status code: ${response.statusCode}';
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching driver profile: $e');
      debugPrint('Stack trace: $stackTrace');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      debugPrint('Updating profile at: ${ApiConstants.getProfile}');
      final response = await _apiService.patch(ApiConstants.getProfile, data: data);

      debugPrint('Update Profile response status: ${response.statusCode}');
      debugPrint('Update Profile response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData is Map<String, dynamic>) {
          if (resData.containsKey('success') && resData['success'] == true && resData.containsKey('data')) {
            final profileResponse = DriverProfileResponse.fromJson(resData);
            if (profileResponse.data != null) {
              driverProfile.value = profileResponse.data;
            }
          } else {
            // Parse unwrapped direct user model response
            driverProfile.value = DriverProfileData.fromJson(resData);
          }
        }
        await fetchDriverProfile();
        return true;
      } else {
        errorMessage.value = 'Failed to update profile. Status code: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      if (e is AppException) {
        errorMessage.value = e.message;
      } else {
        errorMessage.value = e.toString();
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
