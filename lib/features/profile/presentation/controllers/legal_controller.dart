import 'package:flutter/foundation.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/features/profile/data/models/legal_model.dart';
import 'package:get/get.dart';

class LegalController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isFetchingPrivacy = false.obs;
  var isFetchingSupport = false.obs;
  var isSubmittingSupport = false.obs;

  var privacyPolicyText = ''.obs;
  var helpSupportText = ''.obs;

  var errorMessage = ''.obs;

  Future<void> fetchPrivacyPolicy() async {
    try {
      isFetchingPrivacy.value = true;
      errorMessage.value = '';

      // Fetch legal list from backend
      final response = await _apiService.get(
        ApiConstants.legal,
        queryParameters: {
          'type': LegalType.PRIVACY_POLICY.name,
          't': DateTime.now().millisecondsSinceEpoch.toString(), // cache buster
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data;
        if (resData is Map<String, dynamic>) {
          final legalResponse = LegalResponse.fromJson(resData);
          if (legalResponse.success == true && legalResponse.data != null) {
            // Find the PRIVACY_POLICY element
            final policy = legalResponse.data!.firstWhere(
              (e) => e.type == LegalType.PRIVACY_POLICY,
              orElse: () => legalResponse.data!.first,
            );
            
            // Extract text from content
            privacyPolicyText.value = _parseContentText(policy.content);
            return;
          }
        }
      }
      
      // Fallback message if response parsing is empty
      privacyPolicyText.value = '';
    } catch (e) {
      debugPrint('Error fetching privacy policy: $e');
      if (e is AppException) {
        errorMessage.value = e.message;
      } else {
        errorMessage.value = e.toString();
      }
    } finally {
      isFetchingPrivacy.value = false;
    }
  }

  Future<void> fetchHelpSupportContent() async {
    try {
      isFetchingSupport.value = true;
      errorMessage.value = '';

      final response = await _apiService.get(
        ApiConstants.legal,
        queryParameters: {
          'type': LegalType.SUPPORT.name,
          't': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data;
        if (resData is Map<String, dynamic>) {
          final legalResponse = LegalResponse.fromJson(resData);
          if (legalResponse.success == true && legalResponse.data != null) {
            final support = legalResponse.data!.firstWhere(
              (e) => e.type == LegalType.SUPPORT,
              orElse: () => legalResponse.data!.first,
            );
            helpSupportText.value = _parseContentText(support.content);
            return;
          }
        }
      }

      helpSupportText.value = '';
    } catch (e) {
      debugPrint('Error fetching help support content: $e');
      if (e is AppException) {
        errorMessage.value = e.message;
      } else {
        errorMessage.value = e.toString();
      }
    } finally {
      isFetchingSupport.value = false;
    }
  }

  Future<bool> submitHelpRequest(String title, String description) async {
    try {
      isSubmittingSupport.value = true;
      errorMessage.value = '';

      final response = await _apiService.post(
        ApiConstants.legal,
        data: {
          'type': LegalType.SUPPORT.name,
          'content': {
            'title': title,
            'description': description,
          },
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        errorMessage.value = 'Failed to submit request. Status: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting support request: $e');
      if (e is AppException) {
        errorMessage.value = e.message;
      } else {
        errorMessage.value = e.toString();
      }
      return false;
    } finally {
      isSubmittingSupport.value = false;
    }
  }

  String _parseContentText(dynamic content) {
    if (content == null) return '';
    if (content is String) return content;
    if (content is Map) {
      if (content.containsKey('text')) return content['text']?.toString() ?? '';
      if (content.containsKey('content')) return content['content']?.toString() ?? '';
      if (content.containsKey('description')) return content['description']?.toString() ?? '';
      return content.toString();
    }
    return content.toString();
  }
}
