import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/core/services/file_service.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/features/profile/data/models/sos_contact_model.dart';
import 'package:get/get.dart';

class SosController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final FileService _fileService = Get.find<FileService>();

  var isLoading = false.obs;
  var isFetching = false.obs;
  var errorMessage = ''.obs;
  var contacts = <SosContact>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSosContacts();
  }

  Future<void> fetchSosContacts() async {
    try {
      isFetching.value = true;
      errorMessage.value = '';

      final response = await _apiService.get(
        ApiConstants.sosContacts,
        queryParameters: {
          't': DateTime.now().millisecondsSinceEpoch.toString(), // cache buster
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data;
        if (resData is Map<String, dynamic>) {
          final contactsResponse = SosContactResponse.fromJson(resData);
          if (contactsResponse.success == true && contactsResponse.data != null) {
            contacts.assignAll(contactsResponse.data!);
          } else {
            contacts.clear();
          }
        }
      } else {
        errorMessage.value = 'Failed to fetch contacts. Status: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error fetching SOS contacts: $e');
      if (e is AppException) {
        errorMessage.value = e.message;
      } else {
        errorMessage.value = e.toString();
      }
    } finally {
      isFetching.value = false;
    }
  }

  Future<bool> addSosContact({
    required String name,
    required String phone,
    required String relation,
    File? imageFile,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validate phone number format to match /^\+[1-9]\d{7,14}$/
      final phoneRegex = RegExp(r'^\+[1-9]\d{7,14}$');
      if (!phoneRegex.hasMatch(phone)) {
        errorMessage.value = 'Phone must start with "+" and country code (e.g. +880173396245)';
        return false;
      }

      String? avatarValue;

      // Public durable URL — same pattern as profile avatars.
      if (imageFile != null) {
        avatarValue = await _fileService.uploadPublicAsset(imageFile);
        if (avatarValue == null) {
          errorMessage.value =
              'Failed to upload contact image. Ensure storage public URL is configured.';
          return false;
        }
        if (avatarValue.length > 500) {
          errorMessage.value =
              'Uploaded image URL is too long for contact avatar.';
          return false;
        }
      }

      // Step 2: POST the contact details to the backend
      final response = await _apiService.post(
        ApiConstants.sosContacts,
        data: {
          'name': name,
          'phone': phone,
          'relation': relation,
          'avatar': avatarValue ?? '',
          'priority': 0,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchSosContacts(); // Refresh list after successfully adding a contact
        return true;
      } else {
        errorMessage.value = 'Failed to save contact. Status: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      debugPrint('Error adding SOS contact: $e');
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

  Future<bool> deleteSosContact(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.delete(
        ApiConstants.deleteSosContact(id),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchSosContacts(); // Refresh list after deleting a contact
        return true;
      } else {
        errorMessage.value = 'Failed to delete contact. Status: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting SOS contact: $e');
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
