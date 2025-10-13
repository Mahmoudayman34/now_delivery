
class Pickup {
  final String id;
  final String businessId;
  final Business business;
  final DateTime scheduledTime;
  final PickupStatus status;
  final List<PickupOrder> orders;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? rejectionReason;

  const Pickup({
    required this.id,
    required this.businessId,
    required this.business,
    required this.scheduledTime,
    required this.status,
    required this.orders,
    required this.createdAt,
    this.completedAt,
    this.rejectionReason,
  });

  factory Pickup.fromJson(Map<String, dynamic> json) {
    return Pickup(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      business: Business.fromJson(json['business'] as Map<String, dynamic>),
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      status: PickupStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PickupStatus.assigned,
      ),
      orders: (json['orders'] as List<dynamic>)
          .map((order) => PickupOrder.fromJson(order as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'business': business.toJson(),
      'scheduled_time': scheduledTime.toIso8601String(),
      'status': status.name,
      'orders': orders.map((order) => order.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
    };
  }

  Pickup copyWith({
    String? id,
    String? businessId,
    Business? business,
    DateTime? scheduledTime,
    PickupStatus? status,
    List<PickupOrder>? orders,
    DateTime? createdAt,
    DateTime? completedAt,
    String? rejectionReason,
  }) {
    return Pickup(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      business: business ?? this.business,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      orders: orders ?? this.orders,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  // Helper methods
  bool get isCompleted => status == PickupStatus.completed || 
                         status == PickupStatus.businessClosed || 
                         status == PickupStatus.rejected;

  bool get isAssigned => status == PickupStatus.assigned;

  bool get isInProgress => status == PickupStatus.inProgress;

  int get totalOrders => orders.length;

  int get collectedOrders => orders.where((order) => order.isCollected).length;

  String get statusDisplayName => status.displayName;
}

class Business {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final String? logoUrl;
  final double? latitude;
  final double? longitude;

  const Business({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.logoUrl,
    this.latitude,
    this.longitude,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      logoUrl: json['logo_url'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'logo_url': logoUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class PickupOrder {
  final String orderCode;
  final bool isCollected;
  final DateTime? collectedAt;

  const PickupOrder({
    required this.orderCode,
    required this.isCollected,
    this.collectedAt,
  });

  factory PickupOrder.fromJson(Map<String, dynamic> json) {
    return PickupOrder(
      orderCode: json['order_code'] as String,
      isCollected: json['is_collected'] as bool,
      collectedAt: json['collected_at'] != null 
          ? DateTime.parse(json['collected_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_code': orderCode,
      'is_collected': isCollected,
      'collected_at': collectedAt?.toIso8601String(),
    };
  }

  PickupOrder copyWith({
    String? orderCode,
    bool? isCollected,
    DateTime? collectedAt,
  }) {
    return PickupOrder(
      orderCode: orderCode ?? this.orderCode,
      isCollected: isCollected ?? this.isCollected,
      collectedAt: collectedAt ?? this.collectedAt,
    );
  }
}

enum PickupStatus {
  assigned,
  inProgress,
  completed,
  businessClosed,
  rejected,
}

extension PickupStatusExtension on PickupStatus {
  String get displayName {
    switch (this) {
      case PickupStatus.assigned:
        return 'Assigned';
      case PickupStatus.inProgress:
        return 'In Progress';
      case PickupStatus.completed:
        return 'Completed';
      case PickupStatus.businessClosed:
        return 'Business Closed';
      case PickupStatus.rejected:
        return 'Rejected';
    }
  }

  String get colorCode {
    switch (this) {
      case PickupStatus.assigned:
        return '#2196F3'; // Blue
      case PickupStatus.inProgress:
        return '#FF9800'; // Orange
      case PickupStatus.completed:
        return '#4CAF50'; // Green
      case PickupStatus.businessClosed:
        return '#9E9E9E'; // Grey
      case PickupStatus.rejected:
        return '#F44336'; // Red
    }
  }
}
