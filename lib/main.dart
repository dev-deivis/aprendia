import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/chat/screens/chat_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'shared/models/user_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive para persistencia local
  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileAdapter());

  runApp(
    // ProviderScope es necesario para Riverpod
    const ProviderScope(
      child: AprendiaApp(),
    ),
  );
}

class AprendiaApp extends ConsumerWidget {
  const AprendiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Aprendía',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.onboarding,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.onboarding:
            return MaterialPageRoute(
              builder: (_) => const OnboardingScreen(),
            );
          case AppRoutes.chat:
            // El nivel educativo se pasa como argumento desde el onboarding
            final level = settings.arguments as EducationLevel? ??
                EducationLevel.primaria;
            return MaterialPageRoute(
              builder: (_) => ChatScreen(level: level),
            );
          case AppRoutes.profile:
            return MaterialPageRoute(
              builder: (_) => const ProfileScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const OnboardingScreen(),
            );
        }
      },
    );
  }
}
