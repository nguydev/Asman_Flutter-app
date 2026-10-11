enum LegalType {
  TERMS_AND_CONDITIONS,
  PRIVACY_POLICY,
  COOKIES_POLICY,
  LEGAL_NOTICE,
  SUPPORT,
  FAQ
}

class LegalResponse {
  final bool? success;
  final String? message;
  final int? statusCode;
  final List<LegalModel>? data;

  LegalResponse({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory LegalResponse.fromJson(Map<String, dynamic> json) {
    return LegalResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int?,
      data: json['data'] != null
          ? (json['data'] is List
              ? (json['data'] as List)
                  .map((e) => LegalModel.fromJson(e as Map<String, dynamic>))
                  .toList()
              : [LegalModel.fromJson(json['data'] as Map<String, dynamic>)])
          : null,
    );
  }
}

class LegalModel {
  final String id;
  final LegalType type;
  final dynamic content; // Dynamic Json content
  final String createdAt;
  final String updatedAt;

  LegalModel({
    required this.id,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LegalModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type']?.toString() ?? '';
    final type = LegalType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => LegalType.PRIVACY_POLICY,
    );

    return LegalModel(
      id: json['id']?.toString() ?? '',
      type: type,
      content: json['content'],
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
