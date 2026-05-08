import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/tutor/screens/tutor_chat_screen.dart';
import '../../features/primaria/screens/materias_screen.dart';
import '../../features/primaria/screens/actividad_lectura_screen.dart';
import '../../features/primaria/screens/actividad_mate_screen.dart';
import '../../features/progreso/screens/progreso_screen.dart';
import '../../features/perfil/screens/perfil_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/ejercicio/screens/ejercicio_escritura_screen.dart';
import '../../features/alfabetizacion/screens/alfa_shell.dart';
import '../../features/alfabetizacion/screens/alfa_leccion_screen.dart';
import '../../features/secundaria/screens/home_secundaria_screen.dart';
import '../../features/secundaria/screens/materias_secundaria_screen.dart';
import '../../features/secundaria/screens/materia_secundaria_screen.dart';
import '../../features/secundaria/screens/actividad_secundaria_screen.dart';
import '../../features/secundaria/screens/chat_ia_screen.dart';
import '../../features/secundaria/screens/evaluacion_secundaria_screen.dart';
import '../../features/secundaria/screens/progreso_secundaria_screen.dart';
import '../../providers/progreso_provider.dart';
import '../../shared/widgets/main_shell.dart';
import '../../shared/widgets/secundaria_shell.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // ── Flujo inicial ───────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (_, __) => const OnboardingScreen(),
    ),

    // ── Tutor IA (sin shell) ─────────────────────────────────────────
    GoRoute(
      path: AppRoutes.tutor,
      builder: (_, __) => const TutorChatScreen(),
    ),
    GoRoute(
      path: AppRoutes.chat,
      redirect: (_, __) => AppRoutes.tutor,
    ),

    // ── Alfabetización (shell propio) ────────────────────────────────
    GoRoute(
      path: AppRoutes.alfaHome,
      builder: (_, state) {
        final tab = state.extra as int? ?? 0;
        return AlfaShell(initialTab: tab);
      },
    ),
    GoRoute(
      path: AppRoutes.alfaLeccion,
      builder: (_, __) => const AlfaLeccionScreen(),
    ),

    // ── Pantallas secundarias (sin shell) ───────────────────────────
    GoRoute(
      path: AppRoutes.profile,
      builder: (_, __) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.escritura,
      builder: (_, state) {
        final letter = state.extra as String? ?? 'A';
        return EjercicioEscrituraScreen(letter: letter);
      },
    ),

    // ── Actividades primaria (sin shell — pantalla completa) ─────────
    GoRoute(
      path: AppRoutes.primariaActividadLectura,
      builder: (_, state) => ActividadLecturaScreen(
        temaId: state.extra as String?,
      ),
    ),
    GoRoute(
      path: AppRoutes.primariaActividadMate,
      builder: (_, state) => ActividadMateScreen(
        temaId: state.extra as String?,
      ),
    ),

    // ── Secundaria: rutas fuera del shell ───────────────────────────
    GoRoute(
      path: AppRoutes.secundariaMateria,
      builder: (_, state) => MateriaSecundariaScreen(
        materia: state.extra as Materia?,
      ),
    ),
    GoRoute(
      path: AppRoutes.secundariaActividad,
      builder: (_, state) {
        final datos = state.extra as Map<String, dynamic>?;
        final strDatos = datos?.map((k, v) => MapEntry(k, v.toString()));
        return ActividadSecundariaScreen(datos: strDatos);
      },
    ),
    GoRoute(
      path: AppRoutes.secundariaEvaluacion,
      builder: (_, state) {
        final datos = state.extra as Map<String, dynamic>?;
        final strDatos = datos?.map((k, v) => MapEntry(k, v.toString()));
        return EvaluacionSecundariaScreen(datos: strDatos);
      },
    ),
    GoRoute(
      path: AppRoutes.secundariaChat,
      builder: (_, state) {
        final datos = state.extra as Map<String, dynamic>?;
        final strDatos = datos?.map((k, v) => MapEntry(k, v.toString()));
        return ChatIAScreen(datos: strDatos);
      },
    ),

    // ── Shell principal con BottomNavigationBar (Primaria) ───────────
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.primariaMaterias,
          builder: (_, state) => MateriasScreen(
            materia: state.extra as Materia?,
          ),
        ),
        GoRoute(
          path: AppRoutes.progreso,
          builder: (_, __) => const ProgresoScreen(),
        ),
        GoRoute(
          path: AppRoutes.perfil,
          builder: (_, __) => const PerfilScreen(),
        ),
      ],
    ),

    // ── Secundaria Shell con BottomNavigationBar ─────────────────────
    ShellRoute(
      builder: (context, state, child) => SecundariaShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.secundariaHome,
          builder: (_, __) => const HomeSecundariaScreen(),
        ),
        GoRoute(
          path: AppRoutes.secundariaMaterias,
          builder: (_, __) => const MateriasSecundariaScreen(),
        ),
        GoRoute(
          path: AppRoutes.secundariaProgreso,
          builder: (_, __) => const ProgresoSecundariaScreen(),
        ),
        GoRoute(
          path: AppRoutes.secundariaPerfil,
          builder: (_, __) => const PerfilScreen(),
        ),
      ],
    ),
  ],
);
