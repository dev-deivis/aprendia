import 'package:hive_flutter/hive_flutter.dart';

part 'user_profile.g.dart';

/// Niveles educativos del programa MEVyT/INEA
enum EducationLevel {
  alfabetizacion,
  primaria,
  secundaria,
}

extension EducationLevelExtension on EducationLevel {
  String get displayName {
    switch (this) {
      case EducationLevel.alfabetizacion:
        return 'Alfabetización';
      case EducationLevel.primaria:
        return 'Primaria';
      case EducationLevel.secundaria:
        return 'Secundaria';
    }
  }

  String get description {
    switch (this) {
      case EducationLevel.alfabetizacion:
        return 'Aprendo a leer y escribir por primera vez';
      case EducationLevel.primaria:
        return 'Quiero terminar la primaria';
      case EducationLevel.secundaria:
        return 'Quiero terminar la secundaria';
    }
  }
}

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int educationLevelIndex; // índice del enum EducationLevel

  @HiveField(2)
  final int completedSessions;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime? lastSessionAt;

  UserProfile({
    required this.name,
    required this.educationLevelIndex,
    this.completedSessions = 0,
    DateTime? createdAt,
    this.lastSessionAt,
  }) : createdAt = createdAt ?? DateTime.now();

  EducationLevel get educationLevel =>
      EducationLevel.values[educationLevelIndex];

  UserProfile copyWith({
    String? name,
    int? educationLevelIndex,
    int? completedSessions,
    DateTime? lastSessionAt,
  }) {
    return UserProfile(
      name: name ?? this.name,
      educationLevelIndex: educationLevelIndex ?? this.educationLevelIndex,
      completedSessions: completedSessions ?? this.completedSessions,
      createdAt: createdAt,
      lastSessionAt: lastSessionAt ?? this.lastSessionAt,
    );
  }
}
