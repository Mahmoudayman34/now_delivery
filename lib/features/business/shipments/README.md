# Shipments Module

This is the main shipments module that manages all shipment-related functionality in the Now Delivery app.

## Structure

The shipments module is divided into three main sections:

### 1. Orders (`orders/`)
Handles delivery orders from merchants to customers.
- View and manage active delivery orders
- Track order status and location
- Update delivery progress
- Confirm deliveries

### 2. Pickups (`pickups/`)
Handles pickup requests from merchants.
- View and manage pickup requests
- Schedule and track pickups
- Update pickup status
- Confirm collections

### 3. Returns (`returns/`)
Handles return shipments from customers back to merchants.
- View and manage return shipments
- Track return status
- Process return deliveries
- Confirm return completions

## Main Screen

The `ShipmentsScreen` provides a tabbed interface to access all three sections:

```dart
import 'package:now_delivery/features/business/shipments/screens/shipments_screen.dart';

// Use in navigation
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ShipmentsScreen()),
);
```

## Folder Structure

Each section (orders, pickups, returns) follows the same structure:

```
section/
├── models/      # Data models
├── providers/   # State management (Riverpod)
├── screens/     # UI screens
└── widgets/     # Reusable widgets
```

## Development Guidelines

1. **Separation of Concerns**: Keep orders, pickups, and returns logic separate
2. **Shared Widgets**: Common widgets can be placed in `shipments/widgets/`
3. **Shared Models**: Common models can be placed in `shipments/models/`
4. **State Management**: Use Riverpod providers for state management
5. **Responsive Design**: Ensure all screens work across mobile, tablet, and desktop

## Integration

The shipments screen is integrated into the main navigation through `MainLayout`:

```dart
// In main_layout.dart
import '../../business/shipments/screens/shipments_screen.dart';
```

## TODO

- [ ] Implement orders list and details
- [ ] Implement pickups list and scheduling
- [ ] Implement returns list and processing
- [ ] Add filtering and sorting capabilities
- [ ] Implement real-time updates
- [ ] Add barcode scanning for verification
- [ ] Implement offline support
