class AppRoutes {
  AppRoutes._();

  // ── Flujo inicial ──────────────────────────────────────────────
  static const String splash     = '/';
  static const String onboarding = '/onboarding';

  // ── Shell principal (con BottomNav) ───────────────────────────
  static const String home     = '/home';
  static const String progreso = '/progreso';
  static const String perfil   = '/perfil';

  // ── Tutor IA (sin BottomNav) ──────────────────────────────────
  static const String tutor = '/tutor';

  // ── Primaria ──────────────────────────────────────────────────
  static const String primariaMaterias          = '/primaria/materias';
  static const String primariaActividadLectura  = '/primaria/actividad-lectura';
  static const String primariaActividadMate     = '/primaria/actividad-mate';

  // ── Sección Alfabetización (flujo propio) ─────────────────────
  static const String alfaHome    = '/alfa/home';
  static const String alfaLeccion = '/alfa/leccion';

  // ── Pantallas secundarias ─────────────────────────────────────
  static const String profile  = '/profile';
  static const String escritura = '/escritura';

  // ── Secundaria ────────────────────────────────────────────────
  static const String secundariaHome       = '/secundaria/home';
  static const String secundariaMaterias   = '/secundaria/materias';
  static const String secundariaMateria    = '/secundaria/materia';
  static const String secundariaActividad  = '/secundaria/actividad';
  static const String secundariaChat       = '/secundaria/chat';
  static const String secundariaEvaluacion = '/secundaria/evaluacion';
  static const String secundariaProgreso   = '/secundaria/progreso';
  static const String secundariaPerfil     = '/secundaria/perfil';

  // ── Compatibilidad (redirect → /tutor) ───────────────────────
  static const String chat = '/chat';
}
