import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AlfaProgresoTab extends StatelessWidget {
  final void Function(int) onNavigate;
  const AlfaProgresoTab({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatarBubble(),
                const SizedBox(height: 24),
                _buildProgressSection(),
                const SizedBox(height: 24),
                _buildMedals(),
              ],
            ),
          ),
        ),
        _buildContinuarBtn(context),
      ],
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 60,
        color: AppColors.surface,
        child: const Center(
          child: Text(
            'Mi progreso',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarBubble() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryContainer, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
          const SizedBox(height: 12),
          // Speech bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryContainer, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              '¡Mira todo lo que aprendiste!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    const progress = 0.75;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Progreso de hoy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          // Barra de progreso custom
          LayoutBuilder(
            builder: (context, constraints) {
              final barW = constraints.maxWidth;
              const smileySize = 52.0;
              return SizedBox(
                height: 64,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Fondo de la barra
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3E4946),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    // Relleno verde
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      height: 52,
                      width: barW * progress,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7DDB5B),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    // Porcentaje a la derecha
                    Positioned(
                      right: 16,
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Smiley en el borde del progreso
                    Positioned(
                      left: barW * progress - smileySize / 2,
                      child: Container(
                        width: smileySize,
                        height: smileySize,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFCB3A),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF7DDB5B),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sentiment_very_satisfied_rounded,
                          color: Color(0xFF3E4946),
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Etiqueta de estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.primaryContainer),
            ),
            child: const Text(
              'Llevas 3 de 4 lecciones',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mis medallas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _MedalCard(
              icon: Icons.light_mode_rounded,
              iconColor: AppColors.secondary,
              bgColor: AppColors.secondaryContainer.withValues(alpha: 0.2),
              label: '5 días\nseguidos',
            ),
            const SizedBox(width: 8),
            _MedalCard(
              icon: Icons.grade_rounded,
              iconColor: AppColors.primary,
              bgColor: AppColors.primaryContainer.withValues(alpha: 0.2),
              label: 'Aprendí\nlas vocales',
            ),
            const SizedBox(width: 8),
            _MedalCard(
              icon: Icons.favorite_rounded,
              iconColor: AppColors.error,
              bgColor: AppColors.errorContainer.withValues(alpha: 0.2),
              label: 'Mi primera\npalabra',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContinuarBtn(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () => onNavigate(0),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Seguir aprendiendo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryContainer,
              foregroundColor: AppColors.onSecondaryContainer,
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              elevation: 3,
            ),
          ),
        ),
      ),
    );
  }
}

class _MedalCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;

  const _MedalCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
