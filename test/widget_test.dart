// Test básico de humo para Aprendía
// Verifica que la app arranca y muestra la pantalla de onboarding

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:aprendia/core/constants/app_strings.dart';
import 'package:aprendia/core/theme/app_theme.dart';
import 'package:aprendia/features/onboarding/screens/onboarding_screen.dart';

void main() {
  setUpAll(() async {
    // Hive necesita inicializarse antes de los tests
    await Hive.initFlutter();
  });

  testWidgets('OnboardingScreen muestra el nombre de la app',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      ),
    );

    // Verifica que se muestre el nombre de la aplicación
    expect(find.text(AppStrings.appName), findsOneWidget);
  });

  testWidgets('OnboardingScreen muestra los tres niveles educativos',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      ),
    );

    expect(find.text(AppStrings.levelAlphabetization), findsOneWidget);
    expect(find.text(AppStrings.levelPrimaria), findsOneWidget);
    expect(find.text(AppStrings.levelSecundaria), findsOneWidget);
  });
}
