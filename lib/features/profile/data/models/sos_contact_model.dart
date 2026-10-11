class SosContactResponse {
  final bool? success;
  final String? message;
  final int? statusCode;
  final List<SosContact>? data;

  SosContactResponse({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory SosContactResponse.fromJson(Map<String, dynamic> json) {
    return SosContactResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int?,
      data: json['data'] != null
          ? (json['data'] as List).map((e) => SosContact.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }
}

class SosContact {
  final String id;
  final String avatar;
  final String name;
  final String phone;
  final String relation;
  final int priority;

  SosContact({
    required this.id,
    required this.avatar,
    required this.name,
    required this.phone,
    required this.relation,
    required this.priority,
  });

  factory SosContact.fromJson(Map<String, dynamic> json) {
    return SosContact(
      id: json['id']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      relation: json['relation']?.toString() ?? '',
      priority: json['priority'] is int ? json['priority'] : 0,
    );
  }
}
