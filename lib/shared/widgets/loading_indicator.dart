import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Indicador de carga con tres puntos animados — estilo "escribiendo..."
/// Usado dentro de las burbujas de la tutora mientras la IA responde.
class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // Cada punto tiene un desfase de 1/3 del ciclo para el efecto escalonado
            final delay = index * 0.33;
            final opacity =
                ((_animation.value - delay) % 1.0).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Opacity(
                opacity: opacity < 0.5 ? opacity * 2 : (1 - opacity) * 2,
                child: const CircleAvatar(
                  radius: 5,
                  // Usa el color de outline de la nueva paleta teal
                  backgroundColor: AppColors.outline,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
