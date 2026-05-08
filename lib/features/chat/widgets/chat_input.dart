import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/user_profile.dart';

/// Campo de entrada unificado que permite texto y voz para todos los niveles.
/// Se mantienen los botones rápidos de Sí/No para Alfabetización.
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
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// Inicializa el plugin de Speech-to-Text
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (mounted) setState(() {});
  }

  /// Inicia o detiene la escucha del micrófono
  void _toggleListening() async {
    if (widget.isLoading) return;

    if (_speechToText.isNotListening) {
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
            _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length));
          });
        },
        localeId: 'es_MX', // Idioma español México
      );
    } else {
      await _speechToText.stop();
    }
    setState(() {});
  }

  /// Envía el texto si no está vacío y la IA no está respondiendo
  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;
    
    if (_speechToText.isListening) {
      _speechToText.stop();
      setState(() {});
    }

    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Para alfabetización mostramos botones rápidos extra arriba del input
    final showBinaryButtons = widget.level == EducationLevel.alfabetizacion;
    final isListening = _speechToText.isListening;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showBinaryButtons) _buildBinaryButtons(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Botón de micrófono
                GestureDetector(
                  onTap: _speechEnabled ? _toggleListening : null,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8, bottom: 4),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isListening ? AppColors.error : AppColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: isListening ? Colors.white : AppColors.onSurfaceVariant,
                      size: 26,
                    ),
                  ),
                ),
                // Campo de texto
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: !widget.isLoading,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: widget.level == EducationLevel.secundaria ? 4 : 2,
                    minLines: 1,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: isListening ? 'Escuchando...' : 'Escribe tu mensaje...',
                      hintStyle: TextStyle(
                        color: isListening ? AppColors.error : AppColors.outline,
                        fontSize: 15,
                        fontStyle: isListening ? FontStyle.italic : FontStyle.normal,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón de enviar
                GestureDetector(
                  onTap: widget.isLoading ? null : _send,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
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
          ],
        ),
      ),
    );
  }

  Widget _buildBinaryButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Respuesta afirmativa
          GestureDetector(
            onTap: widget.isLoading ? null : () => widget.onSend('Sí'),
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.thumb_up_rounded,
                color: AppColors.onSecondaryContainer,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Respuesta negativa
          GestureDetector(
            onTap: widget.isLoading ? null : () => widget.onSend('No'),
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.thumb_down_rounded,
                color: AppColors.onSurfaceVariant,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
