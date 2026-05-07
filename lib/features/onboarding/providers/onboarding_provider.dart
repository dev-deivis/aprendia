import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../shared/models/user_profile.dart';

/// Estado del proceso de onboarding
class OnboardingState {
  final String name;
  final EducationLevel? selectedLevel;
  final bool isSaving;
  final String? error;

  const OnboardingState({
    this.name = '',
    this.selectedLevel,
    this.isSaving = false,
    this.error,
  });

  OnboardingState copyWith({
    String? name,
    EducationLevel? selectedLevel,
    bool? isSaving,
    String? error,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }

  bool get isValid =>
      name.trim().length >= 2 && selectedLevel != null;
}

/// Proveedor del onboarding con Riverpod
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setName(String name) {
    state = state.copyWith(name: name, error: null);
  }

  void selectLevel(EducationLevel level) {
    state = state.copyWith(selectedLevel: level, error: null);
  }

  /// Guarda el perfil en Hive y regresa true si fue exitoso
  Future<bool> saveProfile() async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Por favor completa todos los campos.');
      return false;
    }

    state = state.copyWith(isSaving: true, error: null);

    try {
      final box = await Hive.openBox<UserProfile>('user_profile');
      final profile = UserProfile(
        name: state.name.trim(),
        educationLevelIndex: state.selectedLevel!.index,
      );
      await box.put('current', profile);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'No se pudo guardar tu perfil. Intenta de nuevo.',
      );
      return false;
    }
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);

/// Proveedor del perfil del usuario guardado en Hive
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final box = await Hive.openBox<UserProfile>('user_profile');
  return box.get('current');
});
