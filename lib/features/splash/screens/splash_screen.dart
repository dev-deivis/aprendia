import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;
  late final Animation<double> _slideUp;

  bool _animacionLista = false;
  final AudioPlayer _audio = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIn = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _scaleIn = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _slideUp = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward().then((_) {
      if (mounted) setState(() => _animacionLista = true);
    });

    // Reproducir audio al arrancar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audio.play(AssetSource('audio/AudioPantallaBienvenida.mp3'));
    });
  }

  @override
  void dispose() {
    _audio.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: Stack(
        children: [
          // ── Decoración fondo ──────────────────────────────────
          Positioned(
            top: -size.height * 0.08,
            left: -size.width * 0.2,
            child: _Blob(
              width: size.width * 0.72,
              height: size.width * 0.72,
              color: AppColors.primaryFixed.withValues(alpha: 0.28),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.06,
            right: -size.width * 0.18,
            child: _Blob(
              width: size.width * 0.65,
              height: size.width * 0.65,
              color: AppColors.secondaryFixed.withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            top: size.height * 0.38,
            right: -size.width * 0.25,
            child: _Blob(
              width: size.width * 0.5,
              height: size.width * 0.5,
              color: AppColors.tertiaryFixed.withValues(alpha: 0.12),
            ),
          ),

          // ── Contenido principal ───────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Texto superior
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedBuilder(
                      animation: _ctrl,
                      builder: (_, child) => Opacity(
                        opacity: _fadeIn.value,
                        child: Transform.translate(
                          offset: Offset(0, -_slideUp.value * 0.5),
                          child: child,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tu maestro',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                                color: AppColors.onSurface
                                    .withValues(alpha: 0.55),
                                letterSpacing: 0.5,
                                height: 1.2,
                              ),
                            ),
                            Text(
                              'siempre contigo',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                                color: AppColors.onSurface
                                    .withValues(alpha: 0.55),
                                letterSpacing: 0.5,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Logo central
                Expanded(
                  flex: 3,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _ctrl,
                      builder: (_, child) => Opacity(
                        opacity: _fadeIn.value,
                        child: Transform.scale(
                          scale: _scaleIn.value,
                          child: child,
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/LogoAprendIA.png',
                        width: 240,
                      ),
                    ),
                  ),
                ),

                // Texto inferior + dots
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: AnimatedBuilder(
                      animation: _ctrl,
                      builder: (_, child) => Opacity(
                        opacity: _fadeIn.value,
                        child: Transform.translate(
                          offset: Offset(0, _slideUp.value),
                          child: child,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),
                          // Separador decorativo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 28,
                                height: 1.5,
                                color: AppColors.outlineVariant,
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 28,
                                height: 1.5,
                                color: AppColors.outlineVariant,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tutor basado en temarios INEA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Botón continuar (visible solo al terminar la animación) ──
          if (_animacionLista)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Center(
                    child: _ArrowButton(
                      onTap: () {
                        _audio.stop();
                        context.go(AppRoutes.onboarding);
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Círculo decorativo de fondo ───────────────────────────────────
class _Blob extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _Blob({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── Botón flecha animado ──────────────────────────────────────────
class _ArrowButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ArrowButton({required this.onTap});

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;
  late final Animation<double> _arrowSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    _arrowSlide = Tween<double>(begin: 0.0, end: 6.0).animate(
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
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: _pulse.value,
          child: child,
        ),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryContainer.withValues(alpha: 0.45),
                blurRadius: 20,
                spreadRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _arrowSlide,
            builder: (_, __) => Transform.translate(
              offset: Offset(_arrowSlide.value, 0),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.onSecondaryContainer,
                size: 34,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
