class Order {
  final String id;
  final String pickupLocation;
  final String dropoffLocation;
  final String pickupAddress;
  final String dropoffAddress;
  final OrderType type;
  final OrderStatus status;
  final double distance;
  final DateTime? pickupTime;
  final DateTime? deliveryTime;
  final DateTime createdAt;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final String zone;

  const Order({
    required this.id,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.type,
    required this.status,
    required this.distance,
    required this.createdAt,
    required this.zone,
    this.pickupTime,
    this.deliveryTime,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.latitude,
    this.longitude,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      pickupLocation: json['pickup_location'] as String,
      dropoffLocation: json['dropoff_location'] as String,
      pickupAddress: json['pickup_address'] as String,
      dropoffAddress: json['dropoff_address'] as String,
      type: OrderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OrderType.normal,
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      distance: (json['distance'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      zone: json['zone'] as String,
      pickupTime: json['pickup_time'] != null 
          ? DateTime.parse(json['pickup_time'] as String) 
          : null,
      deliveryTime: json['delivery_time'] != null 
          ? DateTime.parse(json['delivery_time'] as String) 
          : null,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      notes: json['notes'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickup_location': pickupLocation,
      'dropoff_location': dropoffLocation,
      'pickup_address': pickupAddress,
      'dropoff_address': dropoffAddress,
      'type': type.name,
      'status': status.name,
      'distance': distance,
      'created_at': createdAt.toIso8601String(),
      'zone': zone,
      'pickup_time': pickupTime?.toIso8601String(),
      'delivery_time': deliveryTime?.toIso8601String(),
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Order copyWith({
    String? id,
    String? pickupLocation,
    String? dropoffLocation,
    String? pickupAddress,
    String? dropoffAddress,
    OrderType? type,
    OrderStatus? status,
    double? distance,
    DateTime? pickupTime,
    DateTime? deliveryTime,
    DateTime? createdAt,
    String? customerName,
    String? customerPhone,
    String? notes,
    double? latitude,
    double? longitude,
    String? zone,
  }) {
    return Order(
      id: id ?? this.id,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      type: type ?? this.type,
      status: status ?? this.status,
      distance: distance ?? this.distance,
      pickupTime: pickupTime ?? this.pickupTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      createdAt: createdAt ?? this.createdAt,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      zone: zone ?? this.zone,
    );
  }
}

enum OrderType {
  normal,
  express,
  scheduled,
}

enum OrderStatus {
  pending,
  readyForPickup,
  assigned,
  pickedUp,
  inTransit,
  delivered,
  cancelled,
}

extension OrderTypeExtension on OrderType {
  String get displayName {
    switch (this) {
      case OrderType.normal:
        return 'Normal';
      case OrderType.express:
        return 'Express';
      case OrderType.scheduled:
        return 'Scheduled';
    }
  }
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case OrderStatus.assigned:
        return 'Assigned';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

