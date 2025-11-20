/// Model representing a delivery order
class Order {
  final String id;
  final String orderNumber;
  final String merchantName;
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final String zone;
  final OrderStatus status;
  final String statusLabel;
  final String statusDescription;
  final DateTime orderDate;
  final DateTime? estimatedDeliveryTime;
  final double totalAmount;
  final double orderFees;
  final String productDescription;
  final int numberOfItems;
  final String orderType;
  final String amountType;
  final bool isExpressShipping;
  final String? specialInstructions;
  final String? smartFlyerBarcode;
  
  // Business information fields
  final String? businessName;
  final String? businessPhone;
  final String? businessAddress;
  final String? businessNearbyLandmark;
  final String? businessCity;
  final String? businessZone;
  final double? businessLatitude;
  final double? businessLongitude;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.merchantName,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    required this.zone,
    required this.status,
    required this.statusLabel,
    required this.statusDescription,
    required this.orderDate,
    this.estimatedDeliveryTime,
    required this.totalAmount,
    required this.orderFees,
    required this.productDescription,
    required this.numberOfItems,
    required this.orderType,
    required this.amountType,
    required this.isExpressShipping,
    this.specialInstructions,
    this.smartFlyerBarcode,
    this.businessName,
    this.businessPhone,
    this.businessAddress,
    this.businessNearbyLandmark,
    this.businessCity,
    this.businessZone,
    this.businessLatitude,
    this.businessLongitude,
  });

  /// Get display order number with fallback to ID
  String get displayOrderNumber => orderNumber.isNotEmpty ? orderNumber : id.substring(0, 8);

  factory Order.fromJson(Map<String, dynamic> json) {
    // Handle both order details API format and pickup API format
    final orderCustomer = json['orderCustomer'] as Map<String, dynamic>? ?? {};
    final orderShipping = json['orderShipping'] as Map<String, dynamic>? ?? {};
    
    // Handle business field: can be either String ID or Map object
    Map<String, dynamic> business = {};
    if (json['business'] is Map<String, dynamic>) {
      business = json['business'] as Map<String, dynamic>;
    } else if (json['business'] is String) {
      // When scanning returns, business is just a String ID
      // We'll use a default merchant name in this case
      business = {};
    }
    
    // For pickup API format
    final deliveryAddress = json['deliveryAddress'] as Map<String, dynamic>? ?? {};
    
    // Parse status from orderStatus field
    final statusValue = json['orderStatus'] as String? ?? 'new';
    final parsedStatus = OrderStatus.fromString(statusValue);
    
    // Determine merchant name from different possible fields
    String merchantName = 'Unknown Merchant';
    if (business['brandInfo']?['brandName'] != null) {
      merchantName = business['brandInfo']['brandName'] as String;
    } else if (business['name'] != null) {
      merchantName = business['name'] as String;
    } else if (json['businessName'] != null) {
      // Try businessName field as fallback
      merchantName = json['businessName'] as String;
    }
    
    // Determine customer info from different possible fields
    String customerName = 'Unknown Customer';
    String customerAddress = 'Unknown Address';
    String customerPhone = 'N/A';
    String zone = 'Unknown Zone';
    
    // Try order details API format first
    if (orderCustomer.isNotEmpty) {
      customerName = orderCustomer['fullName'] as String? ?? 'Unknown Customer';
      customerAddress = orderCustomer['address'] as String? ?? 'Unknown Address';
      customerPhone = orderCustomer['phoneNumber'] as String? ?? 'N/A';
      zone = orderCustomer['zone'] as String? ?? orderCustomer['government'] as String? ?? 'Unknown Zone';
    } 
    // Try pickup API format
    else if (deliveryAddress.isNotEmpty) {
      customerName = 'Customer'; // Pickup API doesn't provide customer name
      customerAddress = '${deliveryAddress['street'] ?? ''}, ${deliveryAddress['city'] ?? ''}'.trim();
      customerPhone = deliveryAddress['phone'] as String? ?? 'N/A';
      zone = deliveryAddress['city'] as String? ?? 'Unknown Zone';
    }
    
    // Determine amount from different possible fields
    double totalAmount = 0.0;
    if (json['totalAmount'] != null) {
      totalAmount = (json['totalAmount'] as num).toDouble();
    } else if (orderShipping['amount'] != null) {
      totalAmount = (orderShipping['amount'] as num).toDouble();
    }
    
    // Determine order type from different possible fields
    String orderType = 'Deliver';
    if (json['orderType'] != null) {
      orderType = json['orderType'] as String;
    } else if (orderShipping['orderType'] != null) {
      orderType = orderShipping['orderType'] as String;
    }
    
    // Determine payment method
    String amountType = 'COD';
    if (json['paymentMethod'] != null) {
      amountType = json['paymentMethod'] as String;
    } else if (orderShipping['amountType'] != null) {
      amountType = orderShipping['amountType'] as String;
    }
    
    // Extract business information if available
    String? businessName;
    String? businessPhone;
    String? businessAddress;
    String? businessNearbyLandmark;
    String? businessCity;
    String? businessZone;
    double? businessLatitude;
    double? businessLongitude;
    
    if (business.isNotEmpty) {
      businessName = business['name'] as String? ?? 
                     business['brandInfo']?['brandName'] as String?;
      
      final pickUpAddress = business['pickUpAdress'] as Map<String, dynamic>?;
      if (pickUpAddress != null) {
        // Get phone from pickUpAdress.pickupPhone
        businessPhone = pickUpAddress['pickupPhone'] as String?;
        businessAddress = pickUpAddress['adressDetails'] as String?;
        businessNearbyLandmark = pickUpAddress['nearbyLandmark'] as String?;
        businessCity = pickUpAddress['city'] as String?;
        businessZone = pickUpAddress['zone'] as String?;
        
        final coordinates = pickUpAddress['coordinates'] as Map<String, dynamic>?;
        if (coordinates != null) {
          businessLatitude = (coordinates['lat'] as num?)?.toDouble();
          businessLongitude = (coordinates['lng'] as num?)?.toDouble();
        }
      }
      
      // Fallback to business.phoneNumber if pickupPhone is not available
      if (businessPhone == null || businessPhone.isEmpty) {
        businessPhone = business['phoneNumber'] as String?;
      }
    }
    
    return Order(
      id: json['_id'] as String? ?? '',
      orderNumber: (json['orderNumber']?.toString() ?? '').isNotEmpty 
          ? json['orderNumber'].toString() 
          : json['_id']?.toString().substring(0, 8) ?? 'N/A',
      merchantName: merchantName,
      customerName: customerName,
      customerAddress: customerAddress,
      customerPhone: customerPhone,
      zone: zone,
      status: parsedStatus,
      statusLabel: json['statusLabel'] as String? ?? parsedStatus.label,
      statusDescription: json['statusDescription'] as String? ?? 'Order created',
      orderDate: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : (json['orderDate'] != null 
              ? DateTime.parse(json['orderDate'] as String)
              : DateTime.now()),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] != null
          ? DateTime.parse(json['estimatedDeliveryTime'] as String)
          : null,
      totalAmount: totalAmount,
      orderFees: (json['orderFees'] as num?)?.toDouble() ?? 0.0,
      productDescription: orderShipping['productDescription'] as String? ?? 'N/A',
      numberOfItems: (orderShipping['numberOfItems'] as num?)?.toInt() ?? 1,
      orderType: orderType,
      amountType: amountType,
      isExpressShipping: json['isExpressShipping'] as bool? ?? orderShipping['isExpressShipping'] as bool? ?? false,
      specialInstructions: json['orderNotes'] as String?,
      smartFlyerBarcode: json['smartFlyerBarcode'] as String?,
      businessName: businessName,
      businessPhone: businessPhone,
      businessAddress: businessAddress,
      businessNearbyLandmark: businessNearbyLandmark,
      businessCity: businessCity,
      businessZone: businessZone,
      businessLatitude: businessLatitude,
      businessLongitude: businessLongitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderNumber': orderNumber,
      'merchantName': merchantName,
      'orderCustomer': {
        'fullName': customerName,
        'phoneNumber': customerPhone,
        'address': customerAddress,
        'zone': zone,
      },
      'orderStatus': status.value,
      'statusLabel': statusLabel,
      'statusDescription': statusDescription,
      'orderDate': orderDate.toIso8601String(),
      'estimatedDeliveryTime': estimatedDeliveryTime?.toIso8601String(),
      'orderFees': orderFees,
      'orderShipping': {
        'productDescription': productDescription,
        'numberOfItems': numberOfItems,
        'orderType': orderType,
        'isExpressShipping': isExpressShipping,
      },
      'orderNotes': specialInstructions,
      'smartFlyerBarcode': smartFlyerBarcode,
    };
  }
}



/// Order status enum
enum OrderStatus {
  newOrder('new'),
  pendingPickup('pendingPickup'),
  pickedUp('pickedUp'),
  packed('packed'),
  shipping('shipping'),
  inProgress('inProgress'),
  outForDelivery('outForDelivery'),
  headingToCustomer('headingToCustomer'),
  delivered('delivered'),
  completed('completed'),
  canceled('canceled'),
  returned('returned'),
  returnInitiated('returnInitiated'),
  returnAssigned('returnAssigned'),
  returnPickedUp('returnPickedUp'),
  inReturnStock('inReturnStock'),
  returnAtWarehouse('returnAtWarehouse'),
  returnInspection('returnInspection'),
  returnProcessing('returnProcessing'),
  returnToBusiness('returnToBusiness'),
  returnCompleted('returnCompleted');

  final String value;
  const OrderStatus(this.value);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value.toLowerCase() == value.toLowerCase(),
      orElse: () => OrderStatus.newOrder,
    );
  }
  
  /// Get human-readable status label
  String get label {
    switch (this) {
      case OrderStatus.newOrder:
        return 'New';
      case OrderStatus.pendingPickup:
        return 'Pending Pickup';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.packed:
        return 'Packed';
      case OrderStatus.shipping:
        return 'Shipping';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.headingToCustomer:
        return 'Heading to Customer';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.canceled:
        return 'Canceled';
      case OrderStatus.returned:
        return 'Returned';
      case OrderStatus.returnInitiated:
        return 'Return Initiated';
      case OrderStatus.returnAssigned:
        return 'Return Assigned';
      case OrderStatus.returnPickedUp:
        return 'Return Picked Up';
      case OrderStatus.inReturnStock:
        return 'In Return Stock';
      case OrderStatus.returnAtWarehouse:
        return 'Return at Warehouse';
      case OrderStatus.returnInspection:
        return 'Return Inspection';
      case OrderStatus.returnProcessing:
        return 'Return Processing';
      case OrderStatus.returnToBusiness:
        return 'Return to Business';
      case OrderStatus.returnCompleted:
        return 'Return Completed';
    }
  }
}
