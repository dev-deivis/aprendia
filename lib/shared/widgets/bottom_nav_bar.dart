import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Barra de navegación persistente en la parte inferior.
class AppBottomNavBar extends StatelessWidget {
  final VoidCallback? onReplay;
  final VoidCallback? onBack;

  const AppBottomNavBar({
    super.key,
    this.onReplay,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavButton(
                icon: Icons.arrow_back_rounded, 
                onTap: onBack,
                label: 'Regresar',
              ),
              _NavButton(
                icon: Icons.replay_rounded, 
                onTap: onReplay,
                label: 'Actualizar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String label;

  const _NavButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.onSurfaceVariant, size: 28),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
