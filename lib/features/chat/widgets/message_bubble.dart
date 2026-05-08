import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/message.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/tutor_avatar.dart';

/// Burbuja de chat adaptada al nivel educativo.
/// - Alfabetización: texto grande + ícono de volumen para indicar TTS
/// - Primaria: texto normal + ícono de descripción
/// - Secundaria: texto completo con mayor densidad de información
class MessageBubble extends StatelessWidget {
  final Message message;
  final EducationLevel level;

  const MessageBubble({
    super.key,
    required this.message,
    required this.level,
  });

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    if (_isUser) return _buildUserBubble();
    return _buildTutorBubble();
  }

  /// Burbuja de la tutora con avatar a la izquierda
  Widget _buildTutorBubble() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 48, top: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar pequeño de la tutora con borde decorativo
          const TutorAvatar(size: 40, showBorder: true),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              // Muestra indicador de escritura o contenido según estado
              child: message.isLoading
                  ? const LoadingIndicator()
                  : _buildTutorContent(),
            ),
          ),
        ],
      ),
    );
  }

  /// Contenido de la burbuja adaptado al nivel educativo del usuario
  Widget _buildTutorContent() {
    switch (level) {
      case EducationLevel.alfabetizacion:
        // Texto grande con ícono de audio para máxima accesibilidad
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.volume_up_rounded,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message.content,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ],
        );
      case EducationLevel.primaria:
        // Texto mediano con ícono de descripción para nivel intermedio
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    message.content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case EducationLevel.secundaria:
        // Texto denso sin ícono para el nivel más avanzado
        return Text(
          message.content,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.onSurface,
            height: 1.55,
          ),
        );
    }
  }

  /// Burbuja del usuario alineada a la derecha con color primario
  Widget _buildUserBubble() {
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 16, top: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Text(
            message.content,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.onPrimary,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
