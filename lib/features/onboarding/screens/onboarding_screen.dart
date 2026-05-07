import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/models/user_profile.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Logo / título
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      AppStrings.appTagline,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Campo del nombre
              const Text(
                AppStrings.nameLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: notifier.setName,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: AppStrings.nameHint,
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 32),

              // Selección de nivel
              const Text(
                AppStrings.onboardingSubtitle,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              _LevelCard(
                title: AppStrings.levelAlphabetization,
                description: AppStrings.levelAlphabetizationDesc,
                icon: Icons.spellcheck_rounded,
                level: EducationLevel.alfabetizacion,
                isSelected:
                    state.selectedLevel == EducationLevel.alfabetizacion,
                onTap: () =>
                    notifier.selectLevel(EducationLevel.alfabetizacion),
              ),
              const SizedBox(height: 12),
              _LevelCard(
                title: AppStrings.levelPrimaria,
                description: AppStrings.levelPrimariaDesc,
                icon: Icons.school_rounded,
                level: EducationLevel.primaria,
                isSelected: state.selectedLevel == EducationLevel.primaria,
                onTap: () => notifier.selectLevel(EducationLevel.primaria),
              ),
              const SizedBox(height: 12),
              _LevelCard(
                title: AppStrings.levelSecundaria,
                description: AppStrings.levelSecundariaDesc,
                icon: Icons.menu_book_rounded,
                level: EducationLevel.secundaria,
                isSelected:
                    state.selectedLevel == EducationLevel.secundaria,
                onTap: () =>
                    notifier.selectLevel(EducationLevel.secundaria),
              ),
              const SizedBox(height: 32),

              // Mensaje de error si ocurre
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Botón continuar
              ElevatedButton(
                onPressed: state.isSaving
                    ? null
                    : () async {
                        final success = await notifier.saveProfile();
                        if (success && context.mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.chat,
                            arguments: state.selectedLevel,
                          );
                        }
                      },
                child: state.isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(AppStrings.continueButton),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final EducationLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
