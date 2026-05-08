import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/models/user_profile.dart';
import '../../../providers/usuario_provider.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.13).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      await _audioPlayer.play(AssetSource('audio/AudioPantallaDeInicio.mp3'));
    }
  }

  Future<void> _selectLevel(EducationLevel level) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    await _audioPlayer.stop();

    final notifier = ref.read(onboardingProvider.notifier);
    notifier.selectLevel(level);
    final ok = await notifier.saveProfile();

    if (ok && mounted) {
      await context.read<UsuarioProvider>().guardarNivel(level.name);
      if (!mounted) return;
      if (level == EducationLevel.alfabetizacion) {
        context.go(AppRoutes.alfaHome);
      } else if (level == EducationLevel.secundaria) {
        context.go(AppRoutes.secundariaHome);
      } else {
        context.go(AppRoutes.home);
      }
    } else if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAvatarSection(),
                  _buildLevelCards(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56,
      color: AppColors.surface,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_rounded,
                color: AppColors.primary, size: 28),
            const SizedBox(width: 6),
            const Text(
              'AprendIA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          // Speech bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: const Text(
              '¿Hasta dónde estudiaste?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          // Triangle pointer
          CustomPaint(
            size: const Size(24, 12),
            painter: _BubbleTrianglePainter(),
          ),
          const SizedBox(height: 4),
          // Avatar circle
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/AvatarProfeXolo.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Pulsing play button
          GestureDetector(
            onTap: _toggleAudio,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) => Transform.scale(
                scale: _isPlaying ? 1.0 : _pulseAnim.value,
                child: child,
              ),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppColors.secondaryContainer.withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _isPlaying
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded,
                  color: AppColors.onSecondaryContainer,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          _LevelCard(
            label: 'Aprender a leer',
            sublabel: 'Letras y palabras',
            bgColor: const Color(0xFFFEF7E6),
            borderColor: const Color(0xFFFDE3B5),
            iconBgColor: AppColors.secondaryContainer,
            iconColor: AppColors.onSecondaryContainer,
            illustration: const _AbcIllustration(),
            onTap: _isSaving ? null : () => _selectLevel(EducationLevel.alfabetizacion),
          ),
          const SizedBox(height: 14),
          _LevelCard(
            label: 'Primaria',
            sublabel: 'Números y materias',
            bgColor: const Color(0xFFE6F1EF),
            borderColor: AppColors.outlineVariant,
            iconBgColor: AppColors.primaryContainer,
            iconColor: AppColors.onPrimaryContainer,
            illustration: const _NotebookIllustration(),
            onTap: _isSaving ? null : () => _selectLevel(EducationLevel.primaria),
          ),
          const SizedBox(height: 14),
          _LevelCard(
            label: 'Secundaria',
            sublabel: 'Aprendizaje avanzado',
            bgColor: const Color(0xFFF4ECF9),
            borderColor: AppColors.tertiaryFixedDim,
            iconBgColor: AppColors.tertiaryContainer,
            iconColor: AppColors.onTertiaryContainer,
            illustration: const _BooksIllustration(),
            onTap: _isSaving ? null : () => _selectLevel(EducationLevel.secundaria),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de nivel ────────────────────────────────────────────
class _LevelCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color bgColor;
  final Color borderColor;
  final Color iconBgColor;
  final Color iconColor;
  final Widget illustration;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.label,
    required this.sublabel,
    required this.bgColor,
    required this.borderColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.illustration,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: borderColor,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Ilustración a la izquierda
              SizedBox(
                width: 72,
                height: 72,
                child: illustration,
              ),
              const SizedBox(width: 14),
              // Texto
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sublabel,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.outline,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Ilustraciones ───────────────────────────────────────────────

/// Letras A B C para la tarjeta de Alfabetización
class _AbcIllustration extends StatelessWidget {
  const _AbcIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'A\nBC',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.secondary,
            height: 1.15,
          ),
        ),
      ),
    );
  }
}

/// Cuaderno con 1 2 3 para Primaria
class _NotebookIllustration extends StatelessWidget {
  const _NotebookIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: _NotebookPainter(),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              '1\n2\n3',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotebookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.primaryFixedDim.withValues(alpha: 0.6)
      ..strokeWidth = 1.2;
    final marginPaint = Paint()
      ..color = AppColors.secondaryContainer.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;

    // Horizontal lines (notebook style)
    for (double y = size.height * 0.28;
        y < size.height * 0.95;
        y += size.height * 0.22) {
      canvas.drawLine(Offset(size.width * 0.12, y),
          Offset(size.width * 0.95, y), linePaint);
    }
    // Vertical margin line
    canvas.drawLine(Offset(size.width * 0.22, size.height * 0.05),
        Offset(size.width * 0.22, size.height * 0.95), marginPaint);
  }

  @override
  bool shouldRepaint(_NotebookPainter _) => false;
}

/// Libros apilados con birrete para Secundaria
class _BooksIllustration extends StatelessWidget {
  const _BooksIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.tertiaryFixed.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Birrete
          const Icon(Icons.school_rounded, color: AppColors.tertiary, size: 26),
          const SizedBox(height: 4),
          // Libros apilados
          ...List.generate(
            3,
            (i) => Container(
              margin: EdgeInsets.only(
                  left: (i * 3).toDouble(), bottom: 3),
              width: 36 - i * 4.0,
              height: 10,
              decoration: BoxDecoration(
                color: [
                  AppColors.tertiary,
                  AppColors.tertiaryContainer,
                  AppColors.tertiaryFixedDim,
                ][i].withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Triángulo de la burbuja de diálogo ──────────────────────────
class _BubbleTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_BubbleTrianglePainter _) => false;
}
