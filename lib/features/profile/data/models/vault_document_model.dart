class VaultResponse {
  final bool? success;
  final String? message;
  final int? statusCode;
  final List<VaultDocument>? data;

  VaultResponse({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory VaultResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    List<VaultDocument>? docs;

    if (raw is List) {
      docs = raw
          .whereType<Map>()
          .map((e) => VaultDocument.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else if (raw is Map) {
      // Paginated envelope: { data: [...], pagination: {...} } nested under data
      final nested = raw['data'] ?? raw['items'];
      if (nested is List) {
        docs = nested
            .whereType<Map>()
            .map((e) => VaultDocument.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    return VaultResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int?,
      data: docs,
    );
  }
}

class VaultDocument {
  final String id;
  final String name;
  final String fileObjectId;
  final String createdAt;
  final String? originalFileName;
  final String? contentType;

  VaultDocument({
    required this.id,
    required this.name,
    required this.fileObjectId,
    required this.createdAt,
    this.originalFileName,
    this.contentType,
  });

  /// Back-compat alias used by older UI call sites.
  String get file => fileObjectId;

  /// Best available label for inferring file type (extension / MIME).
  String get previewHint =>
      originalFileName?.isNotEmpty == true
          ? originalFileName!
          : (contentType?.isNotEmpty == true ? contentType! : name);

  factory VaultDocument.fromJson(Map<String, dynamic> json) {
    String fileId = json['fileObjectId']?.toString() ??
        json['fileId']?.toString() ??
        json['file']?.toString() ??
        '';

    final fileObject = json['fileObject'];
    String? originalName;
    String? contentType;
    if (fileObject is Map) {
      if (fileId.isEmpty || fileId.startsWith('{')) {
        fileId = fileObject['id']?.toString() ?? '';
      }
      originalName = fileObject['originalName']?.toString();
      contentType = fileObject['contentType']?.toString();
    }

    final uploadedAt = json['uploadedAt']?.toString() ??
        json['createdAt']?.toString() ??
        '';

    return VaultDocument(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? originalName ?? 'Document',
      fileObjectId: fileId,
      createdAt: uploadedAt,
      originalFileName: originalName,
      contentType: contentType,
    );
  }
}
