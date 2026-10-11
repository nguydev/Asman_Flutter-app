import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/core/services/file_service.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/features/profile/data/models/vault_document_model.dart';
import 'package:get/get.dart';

class VaultController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final FileService _fileService = Get.find<FileService>();

  var isLoading = false.obs;
  var isFetching = false.obs;
  var errorMessage = ''.obs;
  var documents = <VaultDocument>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    try {
      isFetching.value = true;
      errorMessage.value = '';

      final response = await _apiService.get(
        ApiConstants.vault,
        queryParameters: {
          'limit': '50',
          'page': '1',
          't': DateTime.now().millisecondsSinceEpoch.toString(), // cache buster
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data;
        if (resData is Map<String, dynamic>) {
          final vaultResponse = VaultResponse.fromJson(resData);
          if (vaultResponse.success == true && vaultResponse.data != null) {
            documents.assignAll(vaultResponse.data!);
          } else {
            documents.clear();
          }
        }
      } else {
        errorMessage.value = 'Failed to fetch documents. Status: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error fetching vault documents: $e');
      if (e is AppException) {
        errorMessage.value = e.message;
      } else {
        errorMessage.value = e.toString();
      }
    } finally {
      isFetching.value = false;
    }
  }

  Future<bool> uploadDocument(File file, String name) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Step 1: Upload raw file to S3/GCS directly
      final fileId = await _fileService.uploadFile(file);
      if (fileId == null) {
        errorMessage.value = 'Failed to upload document file';
        return false;
      }

      // Step 2: Attach uploaded file to the driver vault
      final response = await _apiService.post(
        ApiConstants.vault,
        data: {
          'name': name,
          'fileObjectId': fileId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchDocuments(); // Refresh documents list after upload
        return true;
      } else {
        errorMessage.value = 'Failed to save document in Vault. Status: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      debugPrint('Error uploading vault document: $e');
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

  Future<bool> deleteDocument(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.delete(
        ApiConstants.deleteVaultItem(id),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchDocuments(); // Refresh documents list after deleting
        return true;
      } else {
        errorMessage.value = 'Failed to delete document. Status: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting vault document: $e');
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
