# Now Shipping - Flutter Mobile Application

## Project Overview

**Now Shipping** is a comprehensive shipping management mobile application built with Flutter. The app enables businesses to manage their shipping operations, track orders, handle pickups, and provide a complete logistics solution for delivery services.

### Key Information
- **Project Name**: Now Shipping
- **Version**: 1.0.6+6
- **Platform**: Flutter (iOS, Android, Web, macOS, Linux, Windows)
- **State Management**: Riverpod
- **API Base URL**: https://nowshipping.co/api/v1

## Project Structure

```
Now-shipping-/
├── android/                     # Android platform configuration
├── ios/                         # iOS platform configuration
├── web/                         # Web platform configuration
├── macos/                       # macOS platform configuration
├── linux/                       # Linux platform configuration
├── windows/                     # Windows platform configuration
├── assets/                      # Application assets
│   ├── animations/              # Lottie animation files
│   ├── fonts/                   # Custom fonts
│   ├── icons/                   # App icons and UI icons
│   └── images/                  # Images and logos
├── lib/                         # Main application code
│   ├── config/                  # Configuration files
│   ├── constants/               # App constants
│   ├── core/                    # Core utilities and services
│   ├── data/                    # Data layer (models, repositories, services)
│   ├── features/                # Feature modules
│   ├── l10n/                    # Localization files
│   ├── routing/                 # App routing configuration
│   └── main.dart               # Application entry point
├── test/                        # Test files
├── build/                       # Build output (generated)
├── pubspec.yaml                 # Dependencies and configuration
├── README.md                    # Basic project information
├── CHANGELOG.md                 # Version history
├── orders_api.md               # API documentation
├── splash.yaml                  # Splash screen configuration
└── analysis_options.yaml       # Dart analysis configuration
```

## Features Overview

### 1. Authentication System
- **Location**: `lib/features/auth/`
- **Components**:
  - Login screen with form validation
  - Signup screen with account creation
  - Account success confirmation
  - JWT token-based authentication
  - Secure session management

### 2. Business Dashboard
- **Location**: `lib/features/business/dashboard/`
- **Components**:
  - Real-time statistics and analytics
  - Cash summary and financial overview
  - Today's overview with key metrics
  - Profile completion workflow
  - Interactive map integration for location services
  - Payment method configuration
  - Brand information setup

### 3. Order Management
- **Location**: `lib/features/business/orders/`
- **Components**:
  - Complete order lifecycle management
  - Order creation with detailed forms
  - Order editing and status updates
  - Order tracking and history
  - Multiple order types: Deliver, Return, Exchange, Cash Collection
  - Customer information management
  - Delivery fee calculation
  - Print functionality for order receipts

### 4. Pickup Management
- **Location**: `lib/features/business/pickups/`
- **Components**:
  - Pickup request creation
  - Pickup scheduling and tracking
  - Detailed pickup information screens
  - Tabbed interface for pickup details
  - Integration with delivery services

### 5. Wallet & Financial Management
- **Location**: `lib/features/business/wallet/`
- **Components**:
  - Financial transaction tracking
  - Payment history
  - Balance management
  - Revenue analytics

### 6. User Profile & Settings
- **Location**: `lib/features/business/more/`
- **Components**:
  - Personal information management
  - Security settings
  - Language preferences (English/Spanish)
  - Notification settings
  - Help center and support
  - Account deletion functionality
  - Contact us interface

### 7. Onboarding Experience
- **Location**: `lib/features/onboarding/`
- **Components**:
  - Multi-step onboarding flow
  - Interactive page indicators
  - Navigation controls
  - Welcome screens with app introduction

## Technical Architecture

### State Management
- **Framework**: Flutter Riverpod
- **Providers**: Comprehensive provider system for state management
- **Benefits**: 
  - Reactive state updates
  - Dependency injection
  - Testing support
  - Memory efficiency

### Core Services
- **API Service**: HTTP client for backend communication
- **Local Storage**: SharedPreferences for data persistence
- **Authentication Service**: JWT token management
- **Location Services**: Google Maps integration
- **File Services**: Image picking and file handling

### UI/UX Design
- **Theme System**: Light and dark theme support
- **Typography**: Google Fonts integration
- **Responsive Design**: Adaptive layouts for different screen sizes
- **Animations**: Lottie animations for enhanced user experience
- **Icons**: Custom SVG icons and Cupertino icons

## Dependencies

### Core Dependencies
```yaml
flutter_riverpod: ^2.4.9        # State management
go_router: ^12.1.3              # Navigation and routing
http: ^1.1.2                    # HTTP client
intl: ^0.20.2                   # Internationalization
shared_preferences: ^2.2.2      # Local storage
```

### UI & Media Dependencies
```yaml
google_fonts: ^6.1.0            # Typography
image_picker: ^1.0.7            # Camera and gallery access
lottie: ^3.0.0                  # Animations
svg_flutter: ^0.0.1             # SVG support
shimmer: ^3.0.0                 # Loading animations
flutter_spinkit: ^5.2.1         # Loading indicators
```

### Platform Integration
```yaml
google_maps_flutter: ^2.5.3     # Maps integration
geocoding: ^2.1.1               # Location services
mobile_scanner: ^3.5.5          # QR code scanning
url_launcher: ^6.2.4            # External URL handling
open_file: ^3.5.10              # File operations
```

### Development Tools
```yaml
flutter_launcher_icons: ^0.14.3 # App icon generation
flutter_native_splash: ^2.4.6   # Splash screen
flutter_lints: ^3.0.1           # Code analysis
```

## Configuration Files

### Environment Configuration
- **Development**: Points to nowshipping.co API
- **Staging**: Same endpoint as production
- **Production**: https://nowshipping.co/api/v1
- **Features**: Analytics toggle, debug banner control

### App Configuration
- **Orientations**: Portrait only (up and down)
- **Text Scaling**: Fixed at 1.0 (no device scaling)
- **Theme Mode**: Light theme by default
- **Debug Banner**: Disabled in release builds

### Splash Screen
- **Background Color**: #f29620 (Orange)
- **Logo**: assets/images/logo.png
- **Branding**: assets/images/branding.png
- **Android 12**: Adaptive icon support

## API Integration

### Orders API
- **Endpoint**: GET /orders
- **Authentication**: JWT token required
- **Filtering**: Support for order type filtering
- **Sorting**: Orders sorted by date (newest first)
- **Order Types**: Deliver, Return, Exchange, Cash Collection
- **Payment Types**: COD, CD, CC, NA

### Data Models
- **Order Model**: Complete order structure with customer, shipping, and tracking info
- **Customer Model**: Customer information and delivery details
- **User Model**: Business user authentication and profile data
- **Dashboard Model**: Analytics and statistics data
- **Pickup Model**: Pickup request and scheduling information

## Development Setup

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK
- Android Studio / Xcode for platform development
- VS Code or preferred IDE

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure platform-specific settings
4. Run `flutter run` to start development

### Build Commands
```bash
# Development build
flutter run

# Release build for Android
flutter build apk --release

# Release build for iOS
flutter build ios --release

# Generate app icons
flutter pub run flutter_launcher_icons:main

# Generate splash screen
flutter pub run flutter_native_splash:create
```

## Localization

### Supported Languages
- English (primary)
- Spanish (secondary)

### Location
- Localization files: `lib/l10n/`
- ARB files for translation strings
- Integrated with Flutter's internationalization system

## Testing

### Test Structure
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for complete flows
- Test files located in `test/` directory

### Test Coverage
- Authentication flows
- Order management operations
- State management providers
- API service integration

## Build & Deployment

### Platform Support
- **Android**: Full support with APK/AAB generation
- **iOS**: Full support with App Store deployment
- **Web**: Progressive Web App capabilities
- **Desktop**: macOS, Linux, Windows support

### CI/CD Integration
- Automated testing on pull requests
- Build verification for multiple platforms
- Release management with version control

## Version History

### v1.0.6 (Current - 2024-12-20)
- Enhanced pickup management functionality
- Improved dashboard widgets and user experience
- Better state management with Riverpod providers
- Updated app constants and configuration
- Various UI improvements and bug fixes

### v1.0.5 (Previous Release)
- Initial shipping management features
- User authentication system
- Business dashboard implementation
- Pickup creation and management
- Order tracking capabilities
- Multi-language support
- QR code scanning integration
- Google Maps integration
- Responsive design implementation

## Security Features

### Authentication
- JWT token-based authentication
- Secure token storage using SharedPreferences
- Automatic token refresh handling
- Session timeout management

### Data Protection
- Encrypted local storage for sensitive data
- HTTPS communication with backend
- Input validation and sanitization
- Error handling without data exposure

## Performance Optimizations

### UI Performance
- Shimmer loading animations
- Pull-to-refresh functionality
- Efficient list rendering
- Image caching and optimization

### Memory Management
- Proper provider disposal
- Efficient state management
- Optimized asset loading
- Background task handling

## Support & Maintenance

### Error Handling
- Comprehensive exception handling
- User-friendly error messages
- Logging and crash reporting
- Graceful degradation

### Monitoring
- Performance monitoring
- User analytics (production only)
- Crash reporting
- Usage statistics

## Contact Information

For technical support or business inquiries related to the Now Shipping application, please refer to the contact information provided within the app's "Contact Us" section.

---

*This documentation was generated based on the current project structure and codebase analysis. For the most up-to-date information, please refer to the latest code commits and release notes.*
