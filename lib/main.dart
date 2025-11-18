import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/main/widgets/main_layout.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'features/business/dashboard/providers/driver_status_provider.dart';
import 'core/services/firebase_messaging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable all orientations for responsive design
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing Firebase: $e');
  }
  
  // Initialize Firebase Messaging
  if (firebaseInitialized) {
    try {
      final firebaseMessagingService = FirebaseMessagingService();
      await firebaseMessagingService.initialize();
      debugPrint('✅ Firebase Messaging initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Firebase Messaging: $e');
    }
  }
  
  runApp(const ProviderScope(child: MyApp()));
  
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // Global navigator key used for root-level navigation from outside the
  // MaterialApp's widget subtree (e.g., from provider listeners).
  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes here (inside build) so Riverpod's
    // debug assertions are satisfied. This will navigate to LoginScreen when
    // an authenticated user becomes unauthenticated.
    ref.listen(authProvider, (previous, next) {
      final wasAuthenticated = (previous as dynamic)?.isAuthenticated ?? false;
      final isAuthenticated = (next as dynamic).isAuthenticated as bool;

      if (wasAuthenticated && !isAuthenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          debugPrint('🔔 Auth state changed: unauthenticated — navigating to LoginScreen');
          // Use the root navigator key instead of context to guarantee a
          // Navigator is available when performing the operation.
          final nav = _rootNavigatorKey.currentState;
          if (nav == null) {
            debugPrint('⚠️ Root navigator is null - cannot navigate');
            return;
          }

          nav.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        });
      }
    });

    return MaterialApp(
      navigatorKey: _rootNavigatorKey,
      title: 'Now Delivery',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: Consumer(
        builder: (context, ref, child) {
          final onboardingState = ref.watch(onboardingProvider);
          final authState = ref.watch(authProvider);

          // Show loading screen while checking auth status
          if (authState.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Show onboarding if user hasn't seen it yet
          if (!onboardingState.hasSeenOnboarding) {
            return const OnboardingScreen();
          }

          // Show login screen if not authenticated
          if (!authState.isAuthenticated) {
            return const LoginScreen();
          }

          // Show main layout with auto go online
          return const AutoGoOnlineWrapper();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Wrapper widget that automatically sets driver status to online on first load
class AutoGoOnlineWrapper extends ConsumerStatefulWidget {
  const AutoGoOnlineWrapper({super.key});

  @override
  ConsumerState<AutoGoOnlineWrapper> createState() => _AutoGoOnlineWrapperState();
}

class _AutoGoOnlineWrapperState extends ConsumerState<AutoGoOnlineWrapper> {
  bool _hasAutoGoneOnline = false;

  @override
  void initState() {
    super.initState();
    // Trigger auto go online after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoGoOnline();
    });
  }

  Future<void> _autoGoOnline() async {
    if (_hasAutoGoneOnline) return;
    _hasAutoGoneOnline = true;
    
    try {
      // Automatically set driver status to online
      // Wrapped in try-catch to prevent crashes if location services fail
      await ref.read(driverStatusProvider.notifier).setOnline(
        true,
        context: context,
      );
    } catch (e) {
      // Silently fail - user can manually go online later
      debugPrint('Auto go online failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MainLayout();
  }
}
