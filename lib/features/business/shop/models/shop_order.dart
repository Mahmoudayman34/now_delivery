/// Model representing a shop order
class ShopOrder {
  final String id;
  final String orderNumber;
  final ShopOrderStatus status;
  final DateTime? assignedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final ShopBusiness business;
  final ShopCustomer customer;
  final List<ShopOrderItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double deliveryFee;
  final double totalAmount;
  final String paymentStatus;
  final String? paymentMethod;
  final String? notes;
  final String? specialInstructions;
  final List<TrackingHistory> trackingHistory;
  final ShopDeliveryInfo? deliveryInfo;

  const ShopOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.assignedAt,
    required this.createdAt,
    required this.updatedAt,
    this.pickedUpAt,
    this.deliveredAt,
    required this.business,
    required this.customer,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.deliveryFee,
    required this.totalAmount,
    required this.paymentStatus,
    this.paymentMethod,
    this.notes,
    this.specialInstructions,
    required this.trackingHistory,
    this.deliveryInfo,
  });

  factory ShopOrder.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>? ?? {};
    final customer = json['orderCustomer'] as Map<String, dynamic>? ?? {};
    final contactInfo = json['contactInfo'] as Map<String, dynamic>? ?? {};
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final trackingList = json['trackingHistory'] as List<dynamic>? ?? [];
    final deliveryInfoData = json['deliveryInfo'] as Map<String, dynamic>?;

    // Merge contactInfo into customer data for proper parsing
    final customerData = Map<String, dynamic>.from(customer);
    if (contactInfo['phone'] != null && customerData['phoneNumber'] == null) {
      customerData['phoneNumber'] = contactInfo['phone'];
    }
    if (contactInfo['name'] != null && customerData['fullName'] == null) {
      customerData['fullName'] = contactInfo['name'];
    }

    return ShopOrder(
      id: json['_id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? 'N/A',
      status: ShopOrderStatus.fromString(json['status'] as String? ?? 'pending'),
      assignedAt: json['assignedAt'] != null 
          ? DateTime.parse(json['assignedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      pickedUpAt: json['pickedUpAt'] != null 
          ? DateTime.parse(json['pickedUpAt'] as String)
          : null,
      deliveredAt: json['deliveredAt'] != null 
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      business: ShopBusiness.fromJson(business),
      customer: ShopCustomer.fromJson(customerData),
      items: itemsList.map((item) => ShopOrderItem.fromJson(item as Map<String, dynamic>)).toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      paymentMethod: json['paymentMethod'] as String?,
      notes: json['notes'] as String?,
      specialInstructions: json['specialInstructions'] as String?,
      trackingHistory: trackingList.map((track) => TrackingHistory.fromJson(track as Map<String, dynamic>)).toList(),
      deliveryInfo: deliveryInfoData != null ? ShopDeliveryInfo.fromJson(deliveryInfoData) : null,
    );
  }

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);
}

/// Shop order status enum
/// Matches the backend status enum exactly
enum ShopOrderStatus {
  pending('pending'),       // New order
  confirmed('confirmed'),   // Admin confirmed
  assigned('assigned'),     // Assigned to courier
  inTransit('in_transit'),  // On the way
  delivered('delivered'),   // Delivered successfully
  cancelled('cancelled'),   // Cancelled
  returned('returned');     // Returned

  final String value;
  const ShopOrderStatus(this.value);

  static ShopOrderStatus fromString(String value) {
    return ShopOrderStatus.values.firstWhere(
      (status) => status.value.toLowerCase() == value.toLowerCase(),
      orElse: () => ShopOrderStatus.pending,
    );
  }

  String get label {
    switch (this) {
      case ShopOrderStatus.pending:
        return 'Pending';
      case ShopOrderStatus.confirmed:
        return 'Confirmed';
      case ShopOrderStatus.assigned:
        return 'Assigned';
      case ShopOrderStatus.inTransit:
        return 'In Transit';
      case ShopOrderStatus.delivered:
        return 'Delivered';
      case ShopOrderStatus.cancelled:
        return 'Cancelled';
      case ShopOrderStatus.returned:
        return 'Returned';
    }
  }
}

/// Shop business model
class ShopBusiness {
  final String id;
  final String brandName;
  final String? phone;
  final String? email;

  const ShopBusiness({
    required this.id,
    required this.brandName,
    this.phone,
    this.email,
  });

  factory ShopBusiness.fromJson(Map<String, dynamic> json) {
    final brandInfo = json['brandInfo'] as Map<String, dynamic>? ?? {};
    
    return ShopBusiness(
      id: json['_id'] as String? ?? '',
      brandName: brandInfo['brandName'] as String? ?? 'Unknown Store',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );
  }
}

/// Shop customer model
class ShopCustomer {
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String governorate;
  final String? landmark;
  final String? buildingNumber;
  final String? floor;
  final String? apartment;

  const ShopCustomer({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.governorate,
    this.landmark,
    this.buildingNumber,
    this.floor,
    this.apartment,
  });

  factory ShopCustomer.fromJson(Map<String, dynamic> json) {
    return ShopCustomer(
      fullName: json['fullName'] as String? ?? 'Unknown Customer',
      phone: json['phoneNumber'] as String? ?? json['phone'] as String? ?? 'N/A',
      address: json['address'] as String? ?? 'Unknown Address',
      city: json['zone'] as String? ?? json['city'] as String? ?? 'Unknown City',
      governorate: json['government'] as String? ?? json['governorate'] as String? ?? 'Unknown',
      landmark: json['landmark'] as String?,
      buildingNumber: json['buildingNumber'] as String?,
      floor: json['floor'] as String?,
      apartment: json['apartment'] as String?,
    );
  }

  String get fullAddress {
    final parts = <String>[address];
    if (buildingNumber != null) parts.add('Building $buildingNumber');
    if (floor != null) parts.add('Floor $floor');
    if (apartment != null) parts.add('Apt $apartment');
    if (landmark != null) parts.add(landmark!);
    parts.add(city);
    return parts.join(', ');
  }
}

/// Shop order item model
class ShopOrderItem {
  final ShopProduct product;
  final int quantity;
  final double price;
  final double totalPrice;
  final String? notes;

  const ShopOrderItem({
    required this.product,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    this.notes,
  });

  factory ShopOrderItem.fromJson(Map<String, dynamic> json) {
    final productData = json['product'] as Map<String, dynamic>? ?? {};
    
    return ShopOrderItem(
      product: ShopProduct.fromJson(productData),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['unitPrice'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['subtotal'] as num?)?.toDouble() ?? (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
    );
  }
}

/// Shop product model
class ShopProduct {
  final String id;
  final String name;
  final String? nameAr;
  final String? description;
  final String? descriptionAr;
  final List<String> images;
  final String? category;
  final String? categoryAr;
  final String? brand;
  final String? sku;

  const ShopProduct({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    required this.images,
    this.category,
    this.categoryAr,
    this.brand,
    this.sku,
  });

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    final imagesList = json['images'] as List<dynamic>? ?? [];
    
    return ShopProduct(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Product',
      nameAr: json['nameAr'] as String?,
      description: json['description'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      images: imagesList.map((img) => img.toString()).toList(),
      category: json['category'] as String?,
      categoryAr: json['categoryAr'] as String?,
      brand: json['brand'] as String?,
      sku: json['sku'] as String?,
    );
  }

  String get imageUrl => images.isNotEmpty ? images.first : '';
}

/// Tracking history model
class TrackingHistory {
  final String status;
  final DateTime updatedAt;
  final String? updatedBy;
  final String? notes;
  final String? location;

  const TrackingHistory({
    required this.status,
    required this.updatedAt,
    this.updatedBy,
    this.notes,
    this.location,
  });

  factory TrackingHistory.fromJson(Map<String, dynamic> json) {
    return TrackingHistory(
      status: json['status'] as String? ?? 'unknown',
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      updatedBy: json['updatedBy'] as String?,
      notes: json['notes'] as String?,
      location: json['location'] as String?,
    );
  }
}

/// Delivery info model
class ShopDeliveryInfo {
  final String? estimatedDeliveryTime;
  final String? deliveryZone;
  final String? deliveryInstructions;

  const ShopDeliveryInfo({
    this.estimatedDeliveryTime,
    this.deliveryZone,
    this.deliveryInstructions,
  });

  factory ShopDeliveryInfo.fromJson(Map<String, dynamic> json) {
    return ShopDeliveryInfo(
      estimatedDeliveryTime: json['estimatedDeliveryTime'] as String?,
      deliveryZone: json['deliveryZone'] as String?,
      deliveryInstructions: json['deliveryInstructions'] as String?,
    );
  }
}
