import 'package:bloom_app/screens/login_screen.dart';
import 'package:bloom_app/screens/main_scaffold.dart';
import 'package:bloom_app/screens/signup_screen.dart';
import 'package:bloom_app/screens/splash_screen.dart';
import 'package:bloom_app/screens/video_screen.dart';
import 'package:bloom_app/models/yoga_class.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class BloomApp extends StatelessWidget {
  const BloomApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeController.themeModeNotifier,
      builder: (context, ThemeMode mode, _) {
        return MaterialApp(
          title: 'Bloom',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/home': (context) => const MainScaffold(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/video') {
              final yogaClass = settings.arguments as YogaClass;
              return MaterialPageRoute(
                builder: (context) => VideoScreen(yogaClass: yogaClass),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
