/// Model representing a pickup request
class Pickup {
  final String id;
  final String pickupNumber;
  final String merchantName;
  final String merchantAddress;
  final String merchantCity;
  final String merchantZone;
  final String merchantPhone;
  final PickupStatus status;
  final String statusCategory;
  final DateTime pickupDate;
  final DateTime requestDate;
  final int numberOfOrders;
  final double pickupFees;
  final bool isFragileItems;
  final bool isLargeItems;
  final String? pickupNotes;
  final String? nearbyLandmark;
  final List<String> ordersPickedUp;

  const Pickup({
    required this.id,
    required this.pickupNumber,
    required this.merchantName,
    required this.merchantAddress,
    required this.merchantCity,
    required this.merchantZone,
    required this.merchantPhone,
    required this.status,
    required this.statusCategory,
    required this.pickupDate,
    required this.requestDate,
    required this.numberOfOrders,
    required this.pickupFees,
    required this.isFragileItems,
    required this.isLargeItems,
    this.pickupNotes,
    this.nearbyLandmark,
    required this.ordersPickedUp,
  });

  factory Pickup.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>? ?? {};
    final pickUpAddress = business['pickUpAdress'] as Map<String, dynamic>? ?? {};
    
    // Get zone from pickUpAdress, or try to find it from pickUpAddresses array
    String? zone = pickUpAddress['zone'] as String?;
    if (zone == null || zone.isEmpty) {
      // Try to find zone from pickUpAddresses array that matches pickupAddressId
      final pickupAddressId = json['pickupAddressId'] as String?;
      if (pickupAddressId != null) {
        final pickUpAddresses = business['pickUpAddresses'] as List<dynamic>?;
        if (pickUpAddresses != null) {
          for (final address in pickUpAddresses) {
            final addressMap = address as Map<String, dynamic>;
            if (addressMap['addressId'] == pickupAddressId || 
                addressMap['_id']?.toString() == pickupAddressId) {
              zone = addressMap['zone'] as String?;
              break;
            }
          }
        }
      }
      // If still not found, try first address in pickUpAddresses
      if (zone == null || zone.isEmpty) {
        final pickUpAddresses = business['pickUpAddresses'] as List<dynamic>?;
        if (pickUpAddresses != null && pickUpAddresses.isNotEmpty) {
          final firstAddress = pickUpAddresses[0] as Map<String, dynamic>;
          zone = firstAddress['zone'] as String?;
        }
      }
    }
    
    // Get pickupNumber with defensive fallback
    final pickupNumberFromApi = json['pickupNumber']?.toString() ?? '';
    final idValue = json['_id']?.toString() ?? '';
    final pickupNumber = pickupNumberFromApi.isNotEmpty 
        ? pickupNumberFromApi 
        : (idValue.length >= 8 ? idValue.substring(0, 8) : idValue.isNotEmpty ? idValue : 'N/A');
    
    return Pickup(
      id: idValue,
      pickupNumber: pickupNumber,
      merchantName: business['brandInfo']?['brandName'] as String? ?? 'Unknown Merchant',
      merchantAddress: pickUpAddress['adressDetails'] as String? ?? 'Unknown Address',
      merchantCity: pickUpAddress['city'] as String? ?? 'Unknown City',
      merchantZone: zone ?? pickUpAddress['city'] as String? ?? 'Unknown Zone',
      merchantPhone: pickUpAddress['pickupPhone'] as String? ?? json['phoneNumber'] as String? ?? 'N/A',
      status: PickupStatus.fromString(json['picikupStatus'] as String? ?? 'new'),
      statusCategory: json['statusCategory'] as String? ?? 'NEW',
      pickupDate: json['pickupDate'] != null
          ? DateTime.parse(json['pickupDate'] as String)
          : DateTime.now(),
      requestDate: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      numberOfOrders: (json['numberOfOrders'] as num?)?.toInt() ?? 0,
      pickupFees: (json['pickupFees'] as num?)?.toDouble() ?? 0.0,
      isFragileItems: json['isFragileItems'] as bool? ?? false,
      isLargeItems: json['isLargeItems'] as bool? ?? false,
      pickupNotes: json['pickupNotes'] as String?,
      nearbyLandmark: pickUpAddress['nearbyLandmark'] as String?,
      ordersPickedUp: (json['ordersPickedUp'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'pickupNumber': pickupNumber,
      'picikupStatus': status.value,
      'statusCategory': statusCategory,
      'pickupDate': pickupDate.toIso8601String(),
      'createdAt': requestDate.toIso8601String(),
      'numberOfOrders': numberOfOrders,
      'pickupFees': pickupFees,
      'isFragileItems': isFragileItems,
      'isLargeItems': isLargeItems,
      'pickupNotes': pickupNotes,
      'ordersPickedUp': ordersPickedUp,
      'phoneNumber': merchantPhone,
      'business': {
        'brandInfo': {'brandName': merchantName},
        'pickUpAdress': {
          'city': merchantCity,
          'zone': merchantZone,
          'adressDetails': merchantAddress,
          'pickupPhone': merchantPhone,
          'nearbyLandmark': nearbyLandmark,
        },
      },
    };
  }
}

/// Pickup status enum
enum PickupStatus {
  newPickup('new'),
  driverAssigned('driverAssigned'),
  pickedUp('pickedUp'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const PickupStatus(this.value);

  static PickupStatus fromString(String value) {
    return PickupStatus.values.firstWhere(
      (status) => status.value.toLowerCase() == value.toLowerCase(),
      orElse: () => PickupStatus.newPickup,
    );
  }

  /// Get display label for status
  String get label {
    switch (this) {
      case PickupStatus.newPickup:
        return 'New';
      case PickupStatus.driverAssigned:
        return 'Assigned';
      case PickupStatus.pickedUp:
        return 'Picked Up';
      case PickupStatus.completed:
        return 'Completed';
      case PickupStatus.cancelled:
        return 'Cancelled';
    }
  }
}
