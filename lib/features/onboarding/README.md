# Onboarding Feature

This feature implements the onboarding screens for the Now Delivery courier app.

## Overview

The onboarding feature consists of 3 screens that introduce new users to the app's key features:
1. **Deliver Smarter, Faster** - Introduction to the app
2. **Track Every Shipment in Real Time** - Real-time tracking feature
3. **Simplify Your Workday** - Task management capabilities

## Structure

```
onboarding/
├── models/
│   └── onboarding_page.dart          # Data model for onboarding pages
├── providers/
│   └── onboarding_provider.dart      # State management for onboarding status
├── screens/
│   └── onboarding_screen.dart        # Main onboarding screen with PageView
├── widgets/
│   └── onboarding_page_widget.dart   # Individual onboarding page widget
└── onboarding.dart                   # Export file
```

## Features

- **Page Navigation**: Swipe between pages or use navigation buttons
- **Smooth Indicators**: Visual dots showing current page progress
- **Persistent State**: Onboarding shown only once per user
- **Responsive Design**: Adapts to different screen sizes
- **Gradient Background**: Orange gradient matching brand colors
- **Custom Buttons**: 
  - Circular arrow buttons for navigation
  - "Get started" button on the last page
  - Back button on pages 2 and 3

## Usage

The onboarding screen is automatically shown when a user first opens the app. Once completed, it won't be shown again unless the user explicitly resets it.

### Resetting Onboarding (for testing)

```dart
// Reset onboarding to show it again
await ref.read(onboardingProvider.notifier).resetOnboarding();
```

### Checking Onboarding Status

```dart
final onboardingState = ref.watch(onboardingProvider);
if (onboardingState.hasSeenOnboarding) {
  // User has completed onboarding
}
```

## Assets Required

The following image assets are used:
- `assets/images/on boarding- 1.png`
- `assets/images/on boarding- 2.png`
- `assets/images/on boarding- 3.png`

## Dependencies

- `smooth_page_indicator`: For the page indicator dots
- `shared_preferences`: For persisting onboarding completion status
- `flutter_riverpod`: For state management

## State Management

The `OnboardingProvider` manages:
- Whether the user has seen the onboarding (`hasSeenOnboarding`)
- Current page index (`currentPage`)

The state is persisted using `SharedPreferences` with the key `has_seen_onboarding`.

## Integration

The onboarding flow is integrated into `main.dart`:
1. First, check if user has seen onboarding
2. If not, show `OnboardingScreen`
3. After completion, redirect to login screen
4. If authenticated, show main app

## Customization

To modify the onboarding content:
1. Update the `onboardingPages` list in `models/onboarding_page.dart`
2. Replace the images in the `assets/images/` directory
3. Adjust colors in `theme/app_theme.dart` if needed


