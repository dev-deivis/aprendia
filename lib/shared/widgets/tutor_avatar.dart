import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Avatar circular de la tutora con gradiente.
/// Placeholder hasta integrar el Lottie animado.
class TutorAvatar extends StatelessWidget {
  final double size;
  final bool showBorder;

  const TutorAvatar({
    super.key,
    this.size = 56,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Borde opcional para resaltar el avatar en la AppBar del chat
        border: showBorder
            ? Border.all(color: AppColors.primaryContainer, width: 2)
            : null,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryContainer, AppColors.primary],
        ),
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          Icons.auto_stories_rounded,
          color: AppColors.onPrimary,
          // Escala el ícono proporcional al tamaño del contenedor
          size: size * 0.45,
        ),
      ),
    );
  }
}
