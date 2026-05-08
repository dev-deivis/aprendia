import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Barra de navegación persistente en la parte inferior.
/// Aparece en todas las pantallas principales.
class AppBottomNavBar extends StatelessWidget {
  final VoidCallback? onReplay;
  final VoidCallback? onMic;
  final VoidCallback? onHelp;

  const AppBottomNavBar({
    super.key,
    this.onReplay,
    this.onMic,
    this.onHelp,
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
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Botón de repetir la última explicación
              _NavButton(
                icon: Icons.replay_rounded,
                onTap: onReplay,
                size: 32,
              ),
              // Botón micrófono — acción principal, resaltado con amber
              GestureDetector(
                onTap: onMic,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: AppColors.onSecondaryContainer,
                    size: 36,
                  ),
                ),
              ),
              // Botón de ayuda contextual
              _NavButton(
                icon: Icons.help_outline_rounded,
                onTap: onHelp,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón de icono sencillo para la barra de navegación
class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  const _NavButton({
    required this.icon,
    this.onTap,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        height: 64,
        child: Center(
          child: Icon(
            icon,
            color: AppColors.onSurfaceVariant,
            size: size,
          ),
        ),
      ),
    );
  }
}
