import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/models/user_profile.dart';
import '../../onboarding/providers/onboarding_provider.dart';

class AlfaPerfilTab extends ConsumerWidget {
  final void Function(int) onNavigate;
  const AlfaPerfilTab({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (profile) => _PerfilContent(
        profile: profile,
        onNavigate: onNavigate,
      ),
    );
  }
}

class _PerfilContent extends StatelessWidget {
  final UserProfile? profile;
  final void Function(int) onNavigate;

  const _PerfilContent({required this.profile, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              children: [
                _buildGreeting(),
                const SizedBox(height: 24),
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _buildLevelBadge(),
                const SizedBox(height: 24),
                _buildModulos(context),
                const SizedBox(height: 24),
                _buildCambiarNivelBtn(context),
              ],
            ),
          ),
        ),
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
            'Mi perfil',
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

  Widget _buildGreeting() {
    final name = profile?.name ?? 'Estudiante';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryFixed, width: 4),
            color: AppColors.primaryContainer,
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.onPrimaryContainer,
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          '¡Vas muy bien, sigue así!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final days = profile != null
        ? DateTime.now().difference(profile!.createdAt).inDays + 1
        : 1;
    final sessions = profile?.completedSessions ?? 0;

    return Row(
      children: [
        _StatCard(
          icon: Icons.local_fire_department_rounded,
          color: AppColors.secondary,
          value: '$days días',
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.stars_rounded,
          color: AppColors.tertiary,
          value: '${sessions * 2} temas',
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.schedule_rounded,
          color: AppColors.primary,
          value: '${(sessions * 0.25).toStringAsFixed(0)} hrs',
        ),
      ],
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF7E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE3B5), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit_rounded,
                color: AppColors.onSecondaryContainer, size: 22),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi nivel actual',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Alfabetización',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModulos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Tu progreso',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        _ProgressRow(label: 'Las vocales', percent: 1.0),
        const SizedBox(height: 10),
        _ProgressRow(label: 'La letra A', percent: 0.5),
        const SizedBox(height: 10),
        _ProgressRow(label: 'Palabras con imágenes', percent: 0.0),
      ],
    );
  }

  Widget _buildCambiarNivelBtn(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => context.go(AppRoutes.onboarding),
        icon: const Icon(Icons.swap_horiz_rounded),
        label: const Text('Cambiar nivel'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurfaceVariant,
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 5),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double percent;

  const _ProgressRow({required this.label, required this.percent});

  @override
  Widget build(BuildContext context) {
    final pct = (percent * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
