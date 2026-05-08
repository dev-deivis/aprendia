import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/user_profile.dart';

/// Campo de entrada adaptado al nivel educativo del usuario.
/// - Alfabetización: solo botones thumb_up / thumb_down (sin teclado)
/// - Primaria: campo de texto pequeño + botón de micrófono
/// - Secundaria: campo de texto completo multilínea + botón de enviar
class LevelAwareChatInput extends StatefulWidget {
  final EducationLevel level;
  final void Function(String) onSend;
  final bool isLoading;

  const LevelAwareChatInput({
    super.key,
    required this.level,
    required this.onSend,
    this.isLoading = false,
  });

  @override
  State<LevelAwareChatInput> createState() => _LevelAwareChatInputState();
}

class _LevelAwareChatInputState extends State<LevelAwareChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  /// Envía el texto si no está vacío y la IA no está respondiendo
  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.level) {
      case EducationLevel.alfabetizacion:
        return _buildBinaryInput();
      case EducationLevel.primaria:
        return _buildPrimariaInput();
      case EducationLevel.secundaria:
        return _buildSecundariaInput();
    }
  }

  /// Alfabetización — solo botones de sí/no para minimizar la barrera de escritura
  Widget _buildBinaryInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Respuesta afirmativa — thumb up con color secundario cálido
            GestureDetector(
              onTap: widget.isLoading ? null : () => widget.onSend('Sí'),
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.thumb_up_rounded,
                  color: AppColors.onSecondaryContainer,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 32),
            // Respuesta negativa — thumb down con color neutro
            GestureDetector(
              onTap: widget.isLoading ? null : () => widget.onSend('No'),
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.thumb_down_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Primaria — campo de texto con ícono de micrófono y botón de enviar
  Widget _buildPrimariaInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Ícono de micrófono como acceso rápido a voz (placeholder)
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !widget.isLoading,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Escribe tu respuesta...',
                  hintStyle: const TextStyle(
                    color: AppColors.outline,
                    fontSize: 15,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  isDense: true,
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 10),
            // Botón circular de enviar con color primario
            GestureDetector(
              onTap: widget.isLoading ? null : _send,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.isLoading
                      ? AppColors.outlineVariant
                      : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Secundaria — campo multilínea completo para preguntas elaboradas
  Widget _buildSecundariaInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !widget.isLoading,
                textCapitalization: TextCapitalization.sentences,
                // Permite hasta 4 líneas para preguntas largas
                maxLines: 4,
                minLines: 1,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Escribe tu pregunta...',
                  hintStyle: const TextStyle(
                    color: AppColors.outline,
                    fontSize: 15,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 10),
            // Botón redondeado de enviar con color secundario amber
            GestureDetector(
              onTap: widget.isLoading ? null : _send,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.isLoading
                      ? AppColors.outlineVariant
                      : AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: widget.isLoading
                      ? AppColors.outline
                      : AppColors.onSecondaryContainer,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
