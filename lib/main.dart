import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:pennywise/screens/splash_screen.dart';
import 'package:pennywise/theme/app_theme.dart';
// import 'package:pennywise/firebase_options.dart'; // Uncomment after running flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  // Uncomment the following line after running: flutterfire configure
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          // Use dynamic colors if available
          lightColorScheme = lightDynamic;
          darkColorScheme = darkDynamic;
        } else {
          // Fallback to custom colors
          lightColorScheme = AppTheme.lightColorScheme;
          darkColorScheme = AppTheme.darkColorScheme;
        }

        return MaterialApp(
          title: 'Daily Expense Book',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme.copyWith(colorScheme: lightColorScheme),
          darkTheme: AppTheme.darkTheme.copyWith(colorScheme: darkColorScheme),
          home: const SplashScreen(),
        );
      },
    );
  }
}
