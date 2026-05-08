import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _tabIndex(String location) {
    if (location.startsWith(AppRoutes.primariaMaterias)) return 1;
    if (location.startsWith(AppRoutes.progreso))         return 2;
    if (location.startsWith(AppRoutes.perfil))           return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _tabIndex(location);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: child,
      floatingActionButton: _TutorFab(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: index,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.onSurfaceVariant,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            onTap: (i) {
              switch (i) {
                case 0: context.go(AppRoutes.home); break;
                case 1: context.go(AppRoutes.primariaMaterias); break;
                case 2: context.go(AppRoutes.progreso); break;
                case 3: context.go(AppRoutes.perfil); break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_rounded),
                label: 'Materias',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded),
                label: 'Progreso',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FAB flotante con avatar tutora ────────────────────────────────
class _TutorFab extends StatefulWidget {
  @override
  State<_TutorFab> createState() => _TutorFabState();
}

class _TutorFabState extends State<_TutorFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.10).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.tutor),
        backgroundColor: AppColors.secondaryContainer,
        foregroundColor: AppColors.onSecondaryContainer,
        elevation: 6,
        tooltip: 'Hablar con la tutora',
        child: const Icon(Icons.smart_toy_rounded, size: 28),
      ),
    );
  }
}
