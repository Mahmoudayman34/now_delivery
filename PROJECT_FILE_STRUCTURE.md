# Now Shipping - Complete File Structure

Based on the PROJECT_DOCUMENTATION.md, here is the complete file structure for the Now Shipping Flutter application:

```
now_delivery/
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
│   │   ├── app/                 # App-specific constants
│   │   ├── api/                 # API-related constants
│   │   └── ui/                  # UI-related constants
│   ├── core/                    # Core utilities and services
│   │   ├── exceptions/          # Custom exceptions
│   │   ├── extensions/          # Dart extensions
│   │   ├── network/             # Network utilities
│   │   ├── services/            # Core services
│   │   └── utils/               # Utility functions
│   ├── data/                    # Data layer
│   │   ├── models/              # Data models
│   │   ├── providers/           # Data providers
│   │   ├── repositories/        # Data repositories
│   │   └── services/            # Data services
│   ├── features/                # Feature modules
│   │   ├── auth/                # Authentication feature
│   │   │   ├── models/          # Auth-specific models
│   │   │   ├── providers/       # Auth providers
│   │   │   ├── screens/         # Auth screens (Login, Signup, etc.)
│   │   │   └── widgets/         # Auth-specific widgets
│   │   ├── business/            # Business features
│   │   │   ├── dashboard/       # Business dashboard
│   │   │   │   ├── providers/   # Dashboard providers
│   │   │   │   ├── screens/     # Dashboard screens
│   │   │   │   └── widgets/     # Dashboard widgets
│   │   │   ├── more/            # Profile & Settings
│   │   │   │   ├── providers/   # More/Settings providers
│   │   │   │   ├── screens/     # Settings screens
│   │   │   │   └── widgets/     # Settings widgets
│   │   │   ├── orders/          # Order management
│   │   │   │   ├── models/      # Order models
│   │   │   │   ├── providers/   # Order providers
│   │   │   │   ├── screens/     # Order screens
│   │   │   │   └── widgets/     # Order widgets
│   │   │   ├── pickups/         # Pickup management
│   │   │   │   ├── providers/   # Pickup providers
│   │   │   │   ├── screens/     # Pickup screens
│   │   │   │   └── widgets/     # Pickup widgets
│   │   │   └── wallet/          # Wallet & Financial management
│   │   │       ├── providers/   # Wallet providers
│   │   │       ├── screens/     # Wallet screens
│   │   │       └── widgets/     # Wallet widgets
│   │   └── onboarding/          # Onboarding experience
│   │       ├── providers/       # Onboarding providers
│   │       ├── screens/         # Onboarding screens
│   │       └── widgets/         # Onboarding widgets
│   ├── l10n/                    # Localization files
│   │   └── arb/                 # ARB translation files
│   ├── routing/                 # App routing configuration
│   │   ├── guards/              # Route guards
│   │   └── routes/              # Route definitions
│   ├── shared/                  # Shared components
│   │   ├── components/          # Reusable components
│   │   └── widgets/             # Shared widgets
│   ├── theme/                   # App theming
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

## Feature Structure Breakdown

### Authentication System (`lib/features/auth/`)
- **Screens**: Login, Signup, Account Success
- **Widgets**: Form components, validation widgets
- **Providers**: Auth state management
- **Models**: User models, auth response models

### Business Dashboard (`lib/features/business/dashboard/`)
- **Screens**: Main dashboard, analytics view
- **Widgets**: Statistics cards, charts, cash summary
- **Providers**: Dashboard data providers

### Order Management (`lib/features/business/orders/`)
- **Screens**: Order list, order details, create/edit order
- **Widgets**: Order cards, status indicators, forms
- **Providers**: Order state management
- **Models**: Order, customer, delivery models

### Pickup Management (`lib/features/business/pickups/`)
- **Screens**: Pickup list, pickup details, create pickup
- **Widgets**: Pickup cards, scheduling widgets
- **Providers**: Pickup state management

### Wallet & Financial (`lib/features/business/wallet/`)
- **Screens**: Wallet overview, transaction history
- **Widgets**: Balance cards, transaction items
- **Providers**: Wallet state management

### Profile & Settings (`lib/features/business/more/`)
- **Screens**: Profile, settings, help center, contact us
- **Widgets**: Settings items, profile forms
- **Providers**: Settings state management

### Onboarding (`lib/features/onboarding/`)
- **Screens**: Welcome screens, app introduction
- **Widgets**: Page indicators, navigation controls
- **Providers**: Onboarding flow management

## Core Architecture

### Data Layer (`lib/data/`)
- **Models**: Data transfer objects and entity models
- **Repositories**: Data access layer abstraction
- **Services**: API services and data sources
- **Providers**: Riverpod providers for data management

### Core Services (`lib/core/`)
- **Services**: HTTP client, authentication, local storage
- **Network**: API configuration and interceptors
- **Utils**: Helper functions and utilities
- **Extensions**: Dart language extensions
- **Exceptions**: Custom exception handling

### Configuration (`lib/config/`, `lib/constants/`)
- App configuration for different environments
- API endpoints and constants
- UI constants (colors, dimensions, etc.)
- App-specific constants

### Routing (`lib/routing/`)
- Route definitions and navigation setup
- Route guards for authentication
- Navigation utilities

### Theming (`lib/theme/`)
- Light and dark theme definitions
- Typography and color schemes
- Component theming

### Shared Components (`lib/shared/`)
- Reusable widgets across features
- Common UI components
- Utility widgets

### Localization (`lib/l10n/`)
- ARB files for English and Spanish
- Internationalization setup

This structure follows Flutter best practices with feature-based organization, clear separation of concerns, and scalable architecture patterns using Riverpod for state management.
