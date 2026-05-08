import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart' as prov;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/usuario_provider.dart';
import 'providers/progreso_provider.dart';
import 'providers/config_provider.dart';
import 'shared/models/user_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileAdapter());

  runApp(
    ProviderScope(
      child: prov.MultiProvider(
        providers: [
          prov.ChangeNotifierProvider(create: (_) => UsuarioProvider()),
          prov.ChangeNotifierProvider(create: (_) => ProgresoProvider()),
          prov.ChangeNotifierProvider(create: (_) => ConfigProvider()),
        ],
        child: const AprendiaApp(),
      ),
    ),
  );
}

class AprendiaApp extends StatelessWidget {
  const AprendiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Aprendía',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
