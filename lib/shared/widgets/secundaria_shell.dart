import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

class SecundariaShell extends StatelessWidget {
  final Widget child;
  const SecundariaShell({super.key, required this.child});

  int _tabIndex(String location) {
    if (location.startsWith(AppRoutes.secundariaMaterias)) return 1;
    if (location.startsWith(AppRoutes.secundariaProgreso)) return 2;
    if (location.startsWith(AppRoutes.secundariaPerfil))   return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _tabIndex(location);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: child,
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
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(icon: Icons.home_rounded,       label: 'Inicio',    selected: index == 0, onTap: () => context.go(AppRoutes.secundariaHome)),
                _NavItem(icon: Icons.menu_book_rounded,  label: 'Materias',  selected: index == 1, onTap: () => context.go(AppRoutes.secundariaMaterias)),
                // Preguntar: PUSH (no es un tab de destino dentro del shell)
                _NavItemAction(
                  icon: Icons.chat_bubble_rounded,
                  label: 'Preguntar',
                  onTap: () => context.push(AppRoutes.secundariaChat),
                ),
                _NavItem(icon: Icons.bar_chart_rounded,  label: 'Progreso',  selected: index == 2, onTap: () => context.go(AppRoutes.secundariaProgreso)),
                _NavItem(icon: Icons.person_rounded,     label: 'Perfil',    selected: index == 3, onTap: () => context.go(AppRoutes.secundariaPerfil)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.onSurfaceVariant;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItemAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.onSecondaryContainer, size: 18),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
