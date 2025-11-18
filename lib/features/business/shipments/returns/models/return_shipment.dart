/// Model representing a return shipment
class ReturnShipment {
  final String id;
  final String orderNumber;
  final String merchantName;
  final String merchantEmail;
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final String zone;
  final ReturnStatus status;
  final String statusCategory;
  final String statusLabel;
  final DateTime orderDate;
  final DateTime? scheduledRetryAt;
  final String returnReason;
  final String? returnNotes;
  final String productDescription;
  final int numberOfItems;
  final double orderFees;
  final double returnFees;
  final double totalFees;
  final int attemptCount;
  final List<String> unavailableReasons;
  final bool isExpressShipping;
  final bool isPartialReturn;
  final String? smartFlyerBarcode;

  const ReturnShipment({
    required this.id,
    required this.orderNumber,
    required this.merchantName,
    required this.merchantEmail,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    required this.zone,
    required this.status,
    required this.statusCategory,
    required this.statusLabel,
    required this.orderDate,
    this.scheduledRetryAt,
    required this.returnReason,
    this.returnNotes,
    required this.productDescription,
    required this.numberOfItems,
    required this.orderFees,
    required this.returnFees,
    required this.totalFees,
    required this.attemptCount,
    required this.unavailableReasons,
    required this.isExpressShipping,
    required this.isPartialReturn,
    this.smartFlyerBarcode,
  });

  factory ReturnShipment.fromJson(Map<String, dynamic> json) {
    final orderCustomer = json['orderCustomer'] as Map<String, dynamic>? ?? {};
    final orderShipping = json['orderShipping'] as Map<String, dynamic>? ?? {};
    final business = json['business'] as Map<String, dynamic>? ?? {};
    
    // Get orderNumber with defensive fallback
    final orderNumberFromApi = json['orderNumber']?.toString() ?? '';
    final idValue = json['_id']?.toString() ?? '';
    final orderNumber = orderNumberFromApi.isNotEmpty 
        ? orderNumberFromApi 
        : (idValue.length >= 8 ? idValue.substring(0, 8) : idValue.isNotEmpty ? idValue : 'N/A');
    
    return ReturnShipment(
      id: idValue,
      orderNumber: orderNumber,
      merchantName: business['brandInfo']?['brandName'] as String? ?? 'Unknown Merchant',
      merchantEmail: business['email'] as String? ?? 'N/A',
      customerName: orderCustomer['fullName'] as String? ?? 'Unknown Customer',
      customerAddress: orderCustomer['address'] as String? ?? 'Unknown Address',
      customerPhone: orderCustomer['phoneNumber'] as String? ?? 'N/A',
      zone: orderCustomer['zone'] as String? ?? 'Unknown Zone',
      status: ReturnStatus.fromString(json['orderStatus'] as String? ?? 'returnInitiated'),
      statusCategory: json['statusCategory'] as String? ?? 'PROCESSING',
      statusLabel: _getStatusLabel(json['orderStatus'] as String? ?? 'returnInitiated'),
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate'] as String)
          : DateTime.now(),
      scheduledRetryAt: json['scheduledRetryAt'] != null
          ? DateTime.parse(json['scheduledRetryAt'] as String)
          : null,
      returnReason: orderShipping['returnReason'] as String? ?? 'Unknown',
      returnNotes: orderShipping['returnNotes'] as String?,
      productDescription: orderShipping['productDescription'] as String? ?? 'No description',
      numberOfItems: (orderShipping['numberOfItems'] as num?)?.toInt() ?? 0,
      orderFees: (json['orderFees'] as num?)?.toDouble() ?? 0.0,
      returnFees: (json['returnFees'] as num?)?.toDouble() ?? 0.0,
      totalFees: (json['totalFees'] as num?)?.toDouble() ?? 0.0,
      attemptCount: (json['Attemps'] as num?)?.toInt() ?? 0,
      unavailableReasons: (json['UnavailableReason'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      isExpressShipping: orderShipping['isExpressShipping'] as bool? ?? false,
      isPartialReturn: orderShipping['isPartialReturn'] as bool? ?? false,
      smartFlyerBarcode: json['smartFlyerBarcode'] as String?,
    );
  }

  static String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'returninitiated':
        return 'Return Initiated';
      case 'returnassigned':
        return 'Return Assigned';
      case 'returnpickedup':
        return 'Return Picked Up';
      case 'inreturnstock':
        return 'In Return Stock';
      case 'returnatwarehouse':
        return 'At Warehouse';
      case 'returninspection':
        return 'Under Inspection';
      case 'returnprocessing':
        return 'Processing';
      case 'returntobusiness':
        return 'Returning to Business';
      case 'returncompleted':
        return 'Completed';
      case 'returntowarehouse':
        return 'Return to Warehouse';
      default:
        return status;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderNumber': orderNumber,
      'orderStatus': status.value,
      'statusCategory': statusCategory,
      'orderDate': orderDate.toIso8601String(),
      'scheduledRetryAt': scheduledRetryAt?.toIso8601String(),
      'orderFees': orderFees,
      'returnFees': returnFees,
      'totalFees': totalFees,
      'Attemps': attemptCount,
      'UnavailableReason': unavailableReasons,
      'smartFlyerBarcode': smartFlyerBarcode,
      'orderCustomer': {
        'fullName': customerName,
        'phoneNumber': customerPhone,
        'address': customerAddress,
        'zone': zone,
      },
      'orderShipping': {
        'productDescription': productDescription,
        'numberOfItems': numberOfItems,
        'returnReason': returnReason,
        'returnNotes': returnNotes,
        'isExpressShipping': isExpressShipping,
        'isPartialReturn': isPartialReturn,
      },
      'business': {
        'brandInfo': {'brandName': merchantName},
        'email': merchantEmail,
      },
    };
  }
}

/// Individual item being returned
class ReturnItem {
  final String name;
  final int quantity;
  final String? condition;

  const ReturnItem({
    required this.name,
    required this.quantity,
    this.condition,
  });

  factory ReturnItem.fromJson(Map<String, dynamic> json) {
    return ReturnItem(
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      condition: json['condition'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'condition': condition,
    };
  }
}

/// Return status enum
enum ReturnStatus {
  returnInitiated('returnInitiated'),
  returnAssigned('returnAssigned'),
  returnPickedUp('returnPickedUp'),
  inReturnStock('inReturnStock'),
  returnAtWarehouse('returnAtWarehouse'),
  returnInspection('returnInspection'),
  returnProcessing('returnProcessing'),
  returnToBusiness('returnToBusiness'),
  returnCompleted('returnCompleted'),
  returnToWarehouse('returnToWarehouse');

  final String value;
  const ReturnStatus(this.value);

  static ReturnStatus fromString(String value) {
    return ReturnStatus.values.firstWhere(
      (status) => status.value.toLowerCase() == value.toLowerCase(),
      orElse: () => ReturnStatus.returnInitiated,
    );
  }

  /// Get display label for status
  String get label {
    switch (this) {
      case ReturnStatus.returnInitiated:
        return 'Return Initiated';
      case ReturnStatus.returnAssigned:
        return 'Return Assigned';
      case ReturnStatus.returnPickedUp:
        return 'Return Picked Up';
      case ReturnStatus.inReturnStock:
        return 'In Return Stock';
      case ReturnStatus.returnAtWarehouse:
        return 'At Warehouse';
      case ReturnStatus.returnInspection:
        return 'Under Inspection';
      case ReturnStatus.returnProcessing:
        return 'Processing';
      case ReturnStatus.returnToBusiness:
        return 'Returning to Business';
      case ReturnStatus.returnCompleted:
        return 'Completed';
      case ReturnStatus.returnToWarehouse:
        return 'Return to Warehouse';
    }
  }
}
