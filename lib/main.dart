import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/main/widgets/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable all orientations for responsive design
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
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
          final authState = ref.watch(authProvider);
          
          // Show login screen if not authenticated
          if (!authState.isAuthenticated) {
            return const LoginScreen();
          }
          
          // Show main layout if authenticated
          return const MainLayout();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}


