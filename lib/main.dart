import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/main/widgets/main_layout.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'features/business/dashboard/providers/driver_status_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable all orientations for responsive design
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const ProviderScope(child: MyApp()));
  
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Now Delivery',
      theme: AppTheme.lightTheme,
      // Explicitly disable dark theme to force light mode only
      darkTheme: null,
      themeMode: ThemeMode.light,
      home: Consumer(
        builder: (context, ref, child) {
          final onboardingState = ref.watch(onboardingProvider);
          final authState = ref.watch(authProvider);
          
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
    
    // Automatically set driver status to online
    await ref.read(driverStatusProvider.notifier).setOnline(true);
  }

  @override
  Widget build(BuildContext context) {
    return const MainLayout();
  }
}
