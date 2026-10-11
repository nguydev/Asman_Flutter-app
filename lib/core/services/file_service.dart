import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:get/get.dart' hide Response, MultipartFile;

/// Result of resolving a file download / public URL.
class FileUrlResult {
  const FileUrlResult({
    required this.url,
    this.expiresIn,
  });

  final String url;
  final int? expiresIn;

  bool get isExpiring => expiresIn != null && expiresIn! > 0;
}

class FileService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  // Memory cache for download URLs to avoid redundant calls during widget redraws
  final _downloadUrlCache = <String, _CachedUrl>{};
  static const _cacheDuration = Duration(minutes: 10);

  // Helper to determine Content-Type based on file extension
  String _getContentType(File file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.gif')) return 'image/gif';
    if (path.endsWith('.webp')) return 'image/webp';
    if (path.endsWith('.pdf')) return 'application/pdf';
    if (path.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (path.endsWith('.doc')) return 'application/msword';
    if (path.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    if (path.endsWith('.xls')) return 'application/vnd.ms-excel';
    if (path.endsWith('.txt')) return 'text/plain';
    if (path.endsWith('.mp4')) return 'video/mp4';
    return 'application/octet-stream';
  }

  /// Request a presigned upload URL from the server.
  /// Returns a Map with the file 'id' and the S3/GCS 'uploadUrl'.
  Future<Map<String, dynamic>?> getUploadUrl({
    required String fileName,
    required String contentType,
    required int fileSize,
    String visibility = 'PRIVATE',
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.filesUploadUrl,
        data: {
          'filename': fileName,
          'contentType': contentType,
          'size': fileSize,
          'visibility': visibility,
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('success') &&
              data['success'] == true &&
              data.containsKey('data')) {
            return data['data'] as Map<String, dynamic>;
          }
          return data;
        }
      }
    } catch (e) {
      debugPrint('Error requesting upload url: $e');
    }
    return null;
  }

  /// Directly upload file bytes to S3/GCS using the presigned URL.
  Future<bool> uploadToPresignedUrl({
    required String uploadUrl,
    required File file,
    required String contentType,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final dio = Dio();

      final response = await dio.put(
        uploadUrl,
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            Headers.contentTypeHeader: contentType,
            Headers.contentLengthHeader: bytes.length,
          },
        ),
        onSendProgress: onSendProgress,
      );

      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      debugPrint('Error uploading bytes directly to presigned URL: $e');
      return false;
    }
  }

  /// Confirm with our backend that the upload has completed.
  Future<bool> completeUpload(String id) async {
    try {
      final response = await _apiService.post(ApiConstants.fileComplete(id));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('success')) {
          return data['success'] == true;
        }
        return true;
      }
    } catch (e) {
      debugPrint('Error completing upload confirmation: $e');
    }
    return false;
  }

  /// Resolve download / public URL details for a file.
  Future<FileUrlResult?> getDownloadUrlDetails(String id) async {
    final cached = _downloadUrlCache[id];
    if (cached != null && !cached.isExpired) {
      return FileUrlResult(url: cached.url, expiresIn: cached.expiresIn);
    }

    try {
      final response = await _apiService.get(ApiConstants.fileDownloadUrl(id));
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final Map<String, dynamic> targetData =
              (data.containsKey('success') &&
                      data['success'] == true &&
                      data.containsKey('data'))
                  ? data['data'] as Map<String, dynamic>
                  : data;

          final url = targetData['downloadUrl']?.toString() ??
              targetData['url']?.toString();
          if (url == null || url.isEmpty) return null;

          final expiresIn = targetData['expiresIn'] is num
              ? (targetData['expiresIn'] as num).toInt()
              : int.tryParse(targetData['expiresIn']?.toString() ?? '');

          final cacheTtl = expiresIn != null && expiresIn > 0
              ? Duration(seconds: (expiresIn * 0.8).floor().clamp(30, 600))
              : _cacheDuration;

          _downloadUrlCache[id] = _CachedUrl(
            url: url,
            expiry: DateTime.now().add(cacheTtl),
            expiresIn: expiresIn,
          );
          return FileUrlResult(url: url, expiresIn: expiresIn);
        }
      }
    } catch (e) {
      debugPrint('Error getting download url for file $id: $e');
    }
    return null;
  }

  /// Get a download / public URL for a file.
  Future<String?> getDownloadUrl(String id) async {
    final details = await getDownloadUrlDetails(id);
    return details?.url;
  }

  /// Delete a file from backend.
  Future<bool> deleteFile(String id) async {
    try {
      final response = await _apiService.delete(ApiConstants.fileDelete(id));
      _downloadUrlCache.remove(id);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('success')) {
          return data['success'] == true;
        }
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting file $id: $e');
    }
    return false;
  }

  /// List the caller's files.
  Future<List<dynamic>?> listFiles({
    String? cursor,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (cursor != null) 'cursor': cursor,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
      };

      final response = await _apiService.get(
        ApiConstants.filesList,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('success') &&
              data['success'] == true &&
              data.containsKey('data')) {
            final dynamic nestedData = data['data'];
            if (nestedData is List) return nestedData;
            if (nestedData is Map && nestedData.containsKey('files')) {
              return nestedData['files'] as List;
            }
          }
          if (data.containsKey('files')) return data['files'] as List;
        } else if (data is List) {
          return data;
        }
      }
    } catch (e) {
      debugPrint('Error listing files: $e');
    }
    return null;
  }

  /// High-level convenience helper: Handles the complete upload lifecycle.
  /// 1. Get presigned URL.
  /// 2. PUT upload S3/GCS.
  /// 3. Confirm completion.
  /// Returns the file 'id' (String) if successful, otherwise null.
  Future<String?> uploadFile(
    File file, {
    String visibility = 'PRIVATE',
    String? contentType,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final size = await file.length();
      final type = contentType ?? _getContentType(file);

      debugPrint(
        'Starting presigned upload for: $fileName ($type, $visibility) - Size: $size bytes',
      );

      final uploadDetails = await getUploadUrl(
        fileName: fileName,
        contentType: type,
        fileSize: size,
        visibility: visibility,
      );

      if (uploadDetails == null) {
        debugPrint('Failed to get presigned upload url details.');
        return null;
      }

      String? fileId;
      String? uploadUrl;

      if (uploadDetails.containsKey('file') && uploadDetails['file'] is Map) {
        fileId = uploadDetails['file']['id']?.toString();
      }
      fileId ??= uploadDetails['id']?.toString();

      if (uploadDetails.containsKey('upload') &&
          uploadDetails['upload'] is Map) {
        uploadUrl = uploadDetails['upload']['url']?.toString();
      }
      uploadUrl ??= uploadDetails['uploadUrl']?.toString();

      if (fileId == null || uploadUrl == null) {
        debugPrint(
          'Missing file ID or uploadUrl in backend response. Details: $uploadDetails',
        );
        return null;
      }

      final directSuccess = await uploadToPresignedUrl(
        uploadUrl: uploadUrl,
        file: file,
        contentType: type,
        onSendProgress: onSendProgress,
      );

      if (!directSuccess) {
        debugPrint('Direct upload to storage provider failed.');
        return null;
      }

      final completeSuccess = await completeUpload(fileId);
      if (!completeSuccess) {
        debugPrint('Backend upload completion check returned failure status.');
        return null;
      }

      return fileId;
    } catch (e) {
      debugPrint('Presigned file upload flow failed: $e');
      return null;
    }
  }

  /// Upload a public media asset (avatars, logos) and return a durable URL
  /// suitable for storing in `avatarUrl` / `logoUrl` fields.
  ///
  /// Requires backend `STORAGE_PUBLIC_BASE_URL` for truly non-expiring URLs.
  /// Returns null if upload fails or only an expiring signed URL is available
  /// when [requireDurable] is true.
  Future<String?> uploadPublicAsset(
    File file, {
    String? contentType,
    void Function(int, int)? onSendProgress,
    bool requireDurable = true,
  }) async {
    final fileId = await uploadFile(
      file,
      visibility: 'PUBLIC',
      contentType: contentType,
      onSendProgress: onSendProgress,
    );
    if (fileId == null) return null;

    final details = await getDownloadUrlDetails(fileId);
    if (details == null || details.url.isEmpty) {
      debugPrint('Failed to resolve public URL for uploaded file $fileId');
      return null;
    }

    if (details.isExpiring) {
      debugPrint(
        '⚠️ PUBLIC upload returned expiring URL (expiresIn=${details.expiresIn}s). '
        'Set STORAGE_PUBLIC_BASE_URL on the API for durable avatar/logo URLs.',
      );
      if (requireDurable) return null;
    }

    return details.url;
  }
}

class _CachedUrl {
  final String url;
  final DateTime expiry;
  final int? expiresIn;

  _CachedUrl({
    required this.url,
    required this.expiry,
    this.expiresIn,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);
}
