import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';

class AlfaHomeTab extends StatefulWidget {
  final void Function(int) onNavigate;
  const AlfaHomeTab({super.key, required this.onNavigate});

  @override
  State<AlfaHomeTab> createState() => _AlfaHomeTabState();
}

class _AlfaHomeTabState extends State<AlfaHomeTab> {
  final AudioPlayer _audio = AudioPlayer();

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _playPageAudio() async {
    await _audio.stop();
    await _audio.play(AssetSource('audio/AudioPantallaDeInicio.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressPath(),
                const SizedBox(height: 28),
                _buildContinuarAprendiendo(context),
                const SizedBox(height: 28),
                _buildActividades(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────
  Widget _buildTopBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: AppColors.surface,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryFixed, width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/AvatarProfeXolo.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '¡Hola!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _playPageAudio,
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.onSecondaryContainer,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Camino de progreso ────────────────────────────────────────
  Widget _buildProgressPath() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Center(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: MediaQuery.of(context).size.width * 0.3,
                  child: Center(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PathDot(completed: true, active: false),
                    _PathDot(completed: true, active: false),
                    _PathDot(completed: false, active: true),
                    _PathDot(completed: false, active: false),
                    _PathDot(completed: false, active: false),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Vas por aquí ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Text('⭐', style: TextStyle(fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Continuar aprendiendo (tutora IA) ─────────────────────────
  Widget _buildContinuarAprendiendo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Continuar aprendiendo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        Material(
          color: AppColors.primaryFixed,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => context.push(AppRoutes.tutor),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.primaryContainer, width: 2),
              ),
              child: Row(
                children: [
                  // Avatar tutora
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/ProfeFeliz.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tutora AprendIA',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '¡Habla conmigo y sigue aprendiendo!',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.mic_rounded,
                                  color: AppColors.onSecondaryContainer,
                                  size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Hablar con la tutora',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.primary, size: 28),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Actividades ───────────────────────────────────────────────
  Widget _buildActividades(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividades',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        _LessonCard(
          icon: Icons.face_rounded,
          label: 'Las vocales',
          subtitle: 'A, E, I, O, U',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _LessonCard(
          icon: Icons.edit_note_rounded,
          label: 'La letra A',
          subtitle: 'Árbol, avión, amor',
          onTap: () => context.push(AppRoutes.alfaLeccion),
        ),
        const SizedBox(height: 12),
        _LessonCard(
          icon: Icons.image_rounded,
          label: 'Palabras con imágenes',
          subtitle: 'Próximamente',
          onTap: null,
          locked: true,
        ),
      ],
    );
  }
}

// ── Widgets locales ───────────────────────────────────────────────

class _PathDot extends StatelessWidget {
  final bool completed;
  final bool active;
  const _PathDot({required this.completed, required this.active});

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 3,
            ),
          ],
        ),
        child: const Icon(Icons.circle_rounded,
            color: AppColors.primary, size: 18),
      );
    }
    if (completed) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
          ],
        ),
        child: const Icon(Icons.star_rounded,
            color: AppColors.onSecondaryContainer, size: 20),
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.circle_outlined,
          color: AppColors.outline, size: 18),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;
  final bool locked;

  const _LessonCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: locked ? 0.5 : 1.0,
      child: Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: locked ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 88,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceVariant, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  locked ? Icons.lock_outline_rounded : Icons.grade_outlined,
                  color: AppColors.outlineVariant,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
