import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/tutor_avatar.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Encabezado con logo y nombre de la app
                SliverToBoxAdapter(child: _buildHeader()),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 32),
                      // Avatar centrado con badge de corazón
                      _buildAvatar(),
                      const SizedBox(height: 24),
                      // Pregunta principal en tamaño grande para fácil lectura
                      const Text(
                        '¿Hasta dónde llegaste en la escuela?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          height: 1.33,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Tarjeta — Alfabetización (nivel inicial)
                      _LevelCard(
                        icon: Icons.edit_rounded,
                        title: 'Aprender a leer y escribir',
                        badge: 'Inicial',
                        badgeColor: AppColors.secondaryContainer,
                        badgeTextColor: AppColors.onSecondaryContainer,
                        iconBgColor:
                            AppColors.secondaryContainer.withValues(alpha: 0.2),
                        iconColor: AppColors.secondary,
                        level: EducationLevel.alfabetizacion,
                        isSelected:
                            state.selectedLevel == EducationLevel.alfabetizacion,
                        onTap: () =>
                            notifier.selectLevel(EducationLevel.alfabetizacion),
                      ),
                      const SizedBox(height: 12),
                      // Tarjeta — Primaria (nivel básico)
                      _LevelCard(
                        icon: Icons.menu_book_rounded,
                        title: 'Primaria',
                        badge: 'Básico',
                        badgeColor: AppColors.primaryFixedDim,
                        badgeTextColor: AppColors.onPrimaryFixedVariant,
                        iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                        iconColor: AppColors.primary,
                        level: EducationLevel.primaria,
                        isSelected:
                            state.selectedLevel == EducationLevel.primaria,
                        onTap: () =>
                            notifier.selectLevel(EducationLevel.primaria),
                      ),
                      const SizedBox(height: 12),
                      // Tarjeta — Secundaria (nivel avanzado)
                      _LevelCard(
                        icon: Icons.school_rounded,
                        title: 'Secundaria',
                        badge: 'Avanzado',
                        badgeColor: AppColors.tertiaryFixed,
                        badgeTextColor: AppColors.onTertiaryFixedVariant,
                        iconBgColor:
                            AppColors.tertiaryFixedDim.withValues(alpha: 0.3),
                        iconColor: AppColors.tertiary,
                        level: EducationLevel.secundaria,
                        isSelected:
                            state.selectedLevel == EducationLevel.secundaria,
                        onTap: () =>
                            notifier.selectLevel(EducationLevel.secundaria),
                      ),
                      const SizedBox(height: 24),
                      // Mensaje informativo que tranquiliza al usuario
                      _buildInfoBox(),
                      const SizedBox(height: 16),
                      // Mensaje de error si ocurre al guardar
                      if (state.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            state.error!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      // Botón principal de continuar
                      ElevatedButton(
                        onPressed:
                            state.isSaving || state.selectedLevel == null
                                ? null
                                : () async {
                                    final success =
                                        await notifier.saveProfile();
                                    if (success && context.mounted) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.chat,
                                        arguments: state.selectedLevel,
                                      );
                                    }
                                  },
                        child: state.isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Continuar'),
                      ),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          // Barra de navegación persistente en la parte inferior
          AppBottomNavBar(
            onReplay: () {},
            onMic: () {},
            onHelp: () {},
          ),
        ],
      ),
    );
  }

  /// Encabezado con logo cuadrado redondeado y nombre de la app
  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // Logo compacto que identifica la app
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: AppColors.onPrimaryContainer,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Aprendía',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Avatar de la tutora con badge de corazón en la esquina inferior derecha
  Widget _buildAvatar() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar principal envuelto en un borde blanco con sombra suave
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const TutorAvatar(size: 96, showBorder: false),
          ),
          // Badge de corazón — transmite calidez y confianza al usuario
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: AppColors.onSecondaryContainer,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Caja informativa que reduce la ansiedad del usuario ante la pregunta
  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No te preocupes, esto es solo para darte las mejores lecciones para ti.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de selección de nivel educativo con animación de selección
class _LevelCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final Color iconBgColor;
  final Color iconColor;
  final EducationLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelCard({
    required this.icon,
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          // Borde primario cuando está seleccionado, transparente si no
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícono del nivel dentro de un círculo con color temático
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            // Nombre del nivel y badge de dificultad
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Badge pill con color temático por nivel
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Chevron indicando que la tarjeta es seleccionable
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.outlineVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
