# Onboarding Feature Implementation

This document explains how the onboarding screens are implemented in the Now Delivery courier app.

## Overview

The onboarding feature consists of 3 screens that introduce new users to the app's key features:
1. **Deliver Smarter, Faster** - Introduction to the app
2. **Track Every Shipment in Real Time** - Real-time tracking feature
3. **Simplify Your Workday** - Task management capabilities

## Architecture

The onboarding feature follows a clean architecture pattern with clear separation of concerns:

```
onboarding/
├── models/
│   └── onboarding_page.dart          # Data model for onboarding pages
├── providers/
│   └── onboarding_provider.dart      # State management (Riverpod)
├── screens/
│   └── onboarding_screen.dart        # Main screen with PageView
├── widgets/
│   └── onboarding_page_widget.dart   # Individual page widget
└── onboarding.dart                   # Barrel export file
```

## Implementation Details

### 1. Data Model (`models/onboarding_page.dart`)

The `OnboardingPageData` class defines the structure for each onboarding page:

```dart
class OnboardingPageData {
  final String title;           // Page title
  final String description;     // Page description text
  final String imagePath;       // Asset path to background image
  final bool isLastPage;        // Flag to identify the last page
}
```

**Key Features:**
- Immutable data class using `const` constructor
- Pre-defined list `onboardingPages` containing all 3 pages
- Each page specifies its image asset path and content

**Usage:**
```dart
final List<OnboardingPageData> onboardingPages = [
  const OnboardingPageData(
    title: 'Deliver Smarter, Faster',
    description: 'Boost your performance and deliver with confidence every time.',
    imagePath: 'assets/images/on boarding- 1.png',
  ),
  // ... more pages
];
```

### 2. State Management (`providers/onboarding_provider.dart`)

Uses **Riverpod** for state management with `StateNotifier` pattern.

#### State Class
```dart
class OnboardingState {
  final bool hasSeenOnboarding;  // Whether user completed onboarding
  final int currentPage;          // Current page index (0-2)
}
```

#### State Notifier
The `OnboardingNotifier` handles:
- **Loading state**: Reads from `SharedPreferences` on initialization
- **Page tracking**: Updates current page index as user navigates
- **Completion**: Persists completion status to `SharedPreferences`
- **Reset**: Allows resetting onboarding for testing

**Key Methods:**
- `_loadOnboardingStatus()`: Loads saved state from SharedPreferences
- `setCurrentPage(int page)`: Updates current page index
- `completeOnboarding()`: Saves completion status and updates state
- `resetOnboarding()`: Resets onboarding status (for testing)

**Persistence:**
- Uses `SharedPreferences` with key `'has_seen_onboarding'`
- Persists boolean value indicating if user has seen onboarding
- Loads automatically when provider initializes

### 3. Page Widget (`widgets/onboarding_page_widget.dart`)

The `OnboardingPageWidget` renders individual onboarding pages with a layered design:

#### Visual Layers (Stack-based):
1. **Background Image Layer**: Full-screen image using `Image.asset` with `BoxFit.cover`
2. **Gradient Overlay Layer**: Orange gradient (`#F29620`) with increasing opacity from top to bottom
   - Transparent at top (0.0)
   - 30% opacity at 50%
   - 70% opacity at 80%
   - 100% opacity at bottom (1.0)
3. **Content Layer**: Text content positioned at bottom
   - Title: 32px, ExtraBold (w800), white color
   - Description: 16px, Medium (w500), white color
   - Uses Google Fonts (Manrope)

**Design Pattern:**
- Uses `Stack` with `StackFit.expand` for full-screen layout
- `IgnorePointer` on gradient to allow interaction with underlying content
- `Positioned` widget for bottom-aligned text content
- Padding: 32px horizontal, 100px top, 140px bottom

### 4. Main Screen (`screens/onboarding_screen.dart`)

The `OnboardingScreen` orchestrates the entire onboarding flow:

#### Components:

**PageView:**
- Uses `PageController` for programmatic navigation
- `PageView.builder` creates pages dynamically from `onboardingPages` list
- Horizontal swipe enabled by default
- Smooth page transitions (300ms, easeInOut curve)

**Navigation Controls:**
- **Back Button**: 
  - Circular white button with orange arrow icon
  - Only visible on pages 2 and 3 (not first page)
  - Calls `_previousPage()` to navigate backward
- **Next Button**: 
  - Circular white button with orange arrow icon
  - Visible on pages 1 and 2
  - Calls `_nextPage()` to navigate forward
- **Get Started Button**:
  - Glassmorphic button with blur effect (`BackdropFilter`)
  - Only visible on last page
  - Calls `_completeOnboarding()` to finish onboarding

**Page Indicator:**
- Uses `SmoothPageIndicator` with `ExpandingDotsEffect`
- White dots with opacity variation (active: 100%, inactive: 40%)
- Responsive sizing (8px on small screens, 10px on larger)

**Responsive Design:**
- Detects screen size: `isSmallScreen = size.width < 600`
- Adjusts button sizes, padding, and font sizes accordingly
- Button sizes: 50x50 (small) vs 60x60 (large)
- Padding: 24px (small) vs 40px (large)

#### State Management Integration:
- Watches `onboardingProvider` for state changes
- Updates provider when page changes: `setCurrentPage(page)`
- Completes onboarding: `completeOnboarding()`
- Navigation handled by parent (main.dart) after completion

## Features

### Page Navigation
- **Swipe**: Horizontal swipe gestures between pages
- **Buttons**: Circular navigation buttons
- **Smooth Transitions**: 300ms animations with easeInOut curve

### Visual Indicators
- **Page Dots**: Expanding dots showing current page and total pages
- **Active State**: Current page dot expands (3x factor)
- **Color Scheme**: White dots matching the design

### Persistent State
- **First Launch**: Onboarding shown only on first app launch
- **Storage**: Uses SharedPreferences for persistence
- **Reset Capability**: Can be reset for testing purposes

### Responsive Design
- **Adaptive Layout**: Adjusts to different screen sizes
- **Breakpoint**: 600px width threshold
- **Scalable Elements**: Buttons, text, and spacing scale appropriately

### Visual Design
- **Gradient Overlay**: Orange brand color gradient (#F29620)
- **Glassmorphism**: Blur effect on "Get Started" button
- **Typography**: Google Fonts (Manrope) for consistent branding
- **Shadows**: Subtle shadows on buttons for depth

## Usage

### Basic Integration

The onboarding screen is automatically shown when a user first opens the app:

```dart
// In main.dart or app initialization
final onboardingState = ref.watch(onboardingProvider);

if (!onboardingState.hasSeenOnboarding) {
  return OnboardingScreen();
} else {
  return LoginScreen(); // or main app
}
```

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
  // Navigate to main app
} else {
  // Show onboarding screen
}
```

### Tracking Current Page

```dart
final onboardingState = ref.watch(onboardingProvider);
final currentPage = onboardingState.currentPage; // 0, 1, or 2
```

## Assets Required

The following image assets must be present in the project:
- `assets/images/on boarding- 1.png` - First onboarding page background
- `assets/images/on boarding- 2.png` - Second onboarding page background
- `assets/images/on boarding- 3.png` - Third onboarding page background

**Image Requirements:**
- Recommended resolution: Match device screen dimensions
- Format: PNG (supports transparency if needed)
- Aspect ratio: Should match target device screens

## Dependencies

Required packages in `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.x.x          # State management
  shared_preferences: ^2.x.x         # Local storage
  smooth_page_indicator: ^1.x.x      # Page indicator dots
  google_fonts: ^6.x.x               # Custom typography
```

## State Flow

```
App Launch
    ↓
Load SharedPreferences
    ↓
Has seen onboarding?
    ├─ No → Show OnboardingScreen
    │        ↓
    │     User swipes/navigates
    │        ↓
    │     User taps "Get Started"
    │        ↓
    │     Save to SharedPreferences
    │        ↓
    └─ Yes → Show Main App
```

## Customization Guide

### Adding/Removing Pages

1. **Update the data model** (`models/onboarding_page.dart`):
```dart
final List<OnboardingPageData> onboardingPages = [
  // Add or remove pages here
  const OnboardingPageData(
    title: 'Your Title',
    description: 'Your description',
    imagePath: 'assets/images/your-image.png',
    isLastPage: false, // Set to true for last page
  ),
];
```

2. **Add corresponding image assets** to `assets/images/` directory
3. **Update `pubspec.yaml`** if needed (usually auto-detected)

### Changing Colors

1. **Gradient Color**: Edit `onboarding_page_widget.dart`
   - Change `Color(0xFFF29620)` to your brand color
   
2. **Button Colors**: Edit `onboarding_screen.dart`
   - Change `AppTheme.primaryOrange` references
   - Modify `Colors.white` for button backgrounds

3. **Theme Colors**: Edit `lib/theme/app_theme.dart`
   - Update `primaryOrange` constant

### Modifying Layout

1. **Text Positioning**: Adjust padding in `OnboardingPageWidget`
   ```dart
   padding: const EdgeInsets.only(
     left: 32,    // Horizontal padding
     right: 32,
     top: 100,    // Distance from bottom
     bottom: 140, // Bottom padding
   ),
   ```

2. **Button Sizes**: Modify in `OnboardingScreen`
   ```dart
   width: isSmallScreen ? 50 : 60,
   height: isSmallScreen ? 50 : 60,
   ```

3. **Gradient Stops**: Adjust in `OnboardingPageWidget`
   ```dart
   stops: const [0.0, 0.5, 0.8, 1.0], // Gradient positions
   ```

### Changing Typography

1. **Font Family**: Change `GoogleFonts.manrope` to another font
2. **Font Sizes**: Modify `fontSize` values in `OnboardingPageWidget`
3. **Font Weights**: Adjust `fontWeight` (w500, w800, etc.)

## Integration with Main App

The onboarding flow integrates with the main app as follows:

1. **App Initialization**: Check onboarding status on app start
2. **Conditional Navigation**: 
   - If not completed → Show `OnboardingScreen`
   - If completed → Show login/main app
3. **Completion Handler**: After "Get Started" is tapped:
   - State is saved to SharedPreferences
   - Navigation is handled by parent widget
   - User proceeds to authentication or main app

## Testing

### Manual Testing Checklist

- [ ] Onboarding shows on first app launch
- [ ] Onboarding doesn't show on subsequent launches
- [ ] Swipe navigation works between pages
- [ ] Back button appears on pages 2 and 3
- [ ] Next button navigates forward
- [ ] "Get Started" appears on last page
- [ ] Page indicator updates correctly
- [ ] Completion persists after app restart
- [ ] Reset function works for testing

### Testing Reset Functionality

```dart
// In a debug menu or test screen
ElevatedButton(
  onPressed: () async {
    await ref.read(onboardingProvider.notifier).resetOnboarding();
    // Navigate back to check onboarding appears
  },
  child: Text('Reset Onboarding'),
)
```

## Troubleshooting

### Onboarding Shows Every Time
- Check SharedPreferences permissions
- Verify `completeOnboarding()` is being called
- Check for exceptions in the completion handler

### Images Not Showing
- Verify image paths in `onboardingPages` list
- Check `pubspec.yaml` includes assets
- Ensure images exist in `assets/images/` directory

### Navigation Not Working
- Verify `PageController` is properly initialized
- Check that `_onPageChanged` is connected to `onPageChanged`
- Ensure provider state updates are working

### State Not Persisting
- Check SharedPreferences package is properly installed
- Verify async/await is used correctly
- Check for exceptions in `_loadOnboardingStatus()`

## Best Practices

1. **State Management**: Always use the provider methods, don't directly modify SharedPreferences
2. **Navigation**: Let parent handle navigation after completion
3. **Error Handling**: The implementation includes try-catch blocks for SharedPreferences operations
4. **Memory Management**: PageController is properly disposed in `dispose()` method
5. **Responsive Design**: Always test on multiple screen sizes
6. **Accessibility**: Consider adding semantic labels for screen readers

## Future Enhancements

Potential improvements:
- Skip button on first page
- Animation between pages
- Video backgrounds instead of images
- Localization support for multiple languages
- Analytics tracking for onboarding completion
- A/B testing different onboarding flows

