class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? type;
  final String? recipient;
  final String? status;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final Map<String, dynamic>? data;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.recipient,
    this.status,
    required this.createdAt,
    this.deliveredAt,
    this.data,
    required this.isRead,
  });

  /// Create NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      type: json['type']?.toString(),
      recipient: json['recipient']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'].toString())
          : null,
      data: json['data'] as Map<String, dynamic>?,
      isRead: (json['isRead'] as bool?) ?? (json['status']?.toString() == 'read'),
    );
  }

  /// Convert NotificationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'body': body,
      'type': type,
      'recipient': recipient,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'data': data,
      'isRead': isRead,
    };
  }

  /// Create a copy of NotificationModel with updated fields
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    String? recipient,
    String? status,
    DateTime? createdAt,
    DateTime? deliveredAt,
    Map<String, dynamic>? data,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      recipient: recipient ?? this.recipient,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, body: $body, type: $type, recipient: $recipient, status: $status, isRead: $isRead, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationModel &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.type == type &&
        other.recipient == recipient &&
        other.status == status &&
        other.isRead == isRead &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        body.hashCode ^
        type.hashCode ^
        recipient.hashCode ^
        status.hashCode ^
        isRead.hashCode ^
        createdAt.hashCode;
  }
}

