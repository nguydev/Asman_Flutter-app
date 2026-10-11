class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? audience;
  final String? userId;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.audience,
    this.userId,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // isRead check: json['readAt'] != null or json['isRead'] == true or json['read'] == true
    final isReadVal = (json['readAt'] != null) ||
        (json['isRead'] == true) ||
        (json['read'] == true);

    return NotificationModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['body'] ?? json['message'] ?? json['description'] ?? '',
      type: json['type'] ??
          (json['channels'] is List && (json['channels'] as List).isNotEmpty
              ? (json['channels'] as List).first.toString()
              : 'IN_APP'),
      isRead: isReadVal,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      audience: json['audience'],
      userId: json['userId'],
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'audience': audience,
      'userId': userId,
      'data': data,
    };
  }
}
