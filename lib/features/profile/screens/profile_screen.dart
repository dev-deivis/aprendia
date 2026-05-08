import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/models/user_profile.dart';
import '../../onboarding/providers/onboarding_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profileTitle)),
      body: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No hay perfil guardado.'));
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar circular con inicial del nombre del usuario
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        profile.name.isNotEmpty
                            ? profile.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppColors.onPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _InfoRow(
                  icon: Icons.school_rounded,
                  label: AppStrings.profileLevel,
                  value: profile.educationLevel.displayName,
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.check_circle_rounded,
                  label: AppStrings.profileSessions,
                  value: '${profile.completedSessions}',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Fila de información del perfil con ícono, etiqueta y valor
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            // Usa la variante de superficie en lugar de textSecondary eliminado
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
