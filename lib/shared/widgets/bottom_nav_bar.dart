import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Barra de navegación persistente en la parte inferior.
/// [onTextSend] — si se provee, muestra el botón de teclado que abre
/// un campo de texto flotante para que el usuario escriba su mensaje.
class AppBottomNavBar extends StatelessWidget {
  final VoidCallback? onReplay;
  final VoidCallback? onMic;
  final VoidCallback? onHelp;
  final void Function(String)? onTextSend;

  const AppBottomNavBar({
    super.key,
    this.onReplay,
    this.onMic,
    this.onHelp,
    this.onTextSend,
  });

  void _abrirTeclado(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TextInputSheet(onSend: onTextSend!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
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
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavButton(icon: Icons.replay_rounded, onTap: onReplay),
              // Mic + teclado juntos en el centro
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón micrófono principal
                  GestureDetector(
                    onTap: onMic,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: AppColors.onSecondaryContainer,
                        size: 32,
                      ),
                    ),
                  ),
                  // Botón teclado — opcional, para escribir texto
                  if (onTextSend != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _abrirTeclado(context),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.keyboard_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              _NavButton(icon: Icons.help_outline_rounded, onTap: onHelp),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hoja modal con campo de texto para escribir un mensaje
class _TextInputSheet extends StatefulWidget {
  final void Function(String) onSend;

  const _TextInputSheet({required this.onSend});

  @override
  State<_TextInputSheet> createState() => _TextInputSheetState();
}

class _TextInputSheetState extends State<_TextInputSheet> {
  final _controller = TextEditingController();

  void _enviar() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    widget.onSend(texto);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Asa visual
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      filled: true,
                      fillColor: AppColors.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _enviar(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _enviar,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
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
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Center(
          child: Icon(icon, color: AppColors.onSurfaceVariant, size: 28),
        ),
      ),
    );
  }
}
