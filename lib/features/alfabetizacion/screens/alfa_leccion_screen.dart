import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';

/// Pantalla de lección: La Letra A
/// Muestra la letra, un ejemplo visual, y un mini-juego de selección.
class AlfaLeccionScreen extends StatefulWidget {
  const AlfaLeccionScreen({super.key});

  @override
  State<AlfaLeccionScreen> createState() => _AlfaLeccionScreenState();
}

class _AlfaLeccionScreenState extends State<AlfaLeccionScreen> {
  final AudioPlayer _audio = AudioPlayer();
  int? _selected; // índice seleccionado en el juego (0=B, 1=A, 2=C)
  bool? _correct;

  static const _choices = ['B', 'A', 'C'];
  static const _correctIndex = 1; // 'A'

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _playLetter() async {
    await _audio.stop();
    // Usa TTS via flutter_tts si se añade; por ahora es stub
  }

  void _choose(int index) {
    if (_selected != null) return;
    setState(() {
      _selected = index;
      _correct = index == _correctIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              child: Column(
                children: [
                  _buildLevelLabel(),
                  const SizedBox(height: 24),
                  _buildIllustration(),
                  const SizedBox(height: 24),
                  _buildGiantLetters(),
                  const SizedBox(height: 28),
                  _buildSelectionGame(),
                  const SizedBox(height: 24),
                  _buildFeedback(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: AppColors.surface,
        child: Row(
          children: [
            // Botón Home
            IconButton(
              onPressed: () =>
                  context.go(AppRoutes.alfaHome),
              icon: const Icon(Icons.home_rounded,
                  color: AppColors.primary, size: 28),
            ),
            // Indicador de progreso (puntos)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final done = i == 0;
                  return Container(
                    width: done ? 14 : 10,
                    height: done ? 14 : 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: done
                          ? AppColors.secondaryContainer
                          : AppColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
            // Botón audio
            IconButton(
              onPressed: _playLetter,
              icon: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volume_up_rounded,
                    color: AppColors.onSecondaryContainer, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelLabel() {
    return const Text(
      'Nivel 1: Introducción',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildIllustration() {
    return Column(
      children: [
        // Caja de ilustración del árbol (con emoji como placeholder)
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text('🌳', style: TextStyle(fontSize: 90)),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Árbol',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGiantLetters() {
    return Column(
      children: [
        const Text(
          'A  a',
          style: TextStyle(
            fontSize: 88,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: 8,
            height: 1,
          ),
        ),
        const SizedBox(height: 16),
        // Botón de escuchar la letra
        GestureDetector(
          onTap: _playLetter,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.volume_up_rounded,
              color: AppColors.onSecondaryContainer,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionGame() {
    return Column(
      children: [
        const Text(
          'Toca la letra que suena:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: List.generate(_choices.length, (i) {
            final isCorrect = i == _correctIndex;
            final isSelected = _selected == i;
            Color bgColor = Colors.white;
            Color borderColor = AppColors.surfaceContainerHighest;
            int borderWidth = 2;

            if (isSelected) {
              if (_correct == true) {
                bgColor = AppColors.primaryFixed;
                borderColor = AppColors.primary;
                borderWidth = 4;
              } else {
                bgColor = AppColors.errorContainer;
                borderColor = AppColors.error;
                borderWidth = 4;
              }
            } else if (isCorrect) {
              borderColor = AppColors.secondaryContainer;
              borderWidth = 4;
            }

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 2 ? 12 : 0),
                child: GestureDetector(
                  onTap: () => _choose(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 100,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: borderColor, width: borderWidth.toDouble()),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _choices[i],
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: isCorrect
                              ? FontWeight.w900
                              : FontWeight.w700,
                          color: isCorrect
                              ? AppColors.primary
                              : AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFeedback() {
    String message;
    Color msgColor;
    IconData msgIcon;

    if (_correct == null) {
      message = 'Escucha y elige la letra A';
      msgColor = AppColors.onSurface;
      msgIcon = Icons.help_outline_rounded;
    } else if (_correct == true) {
      message = '¡Muy bien! Esa es la letra A 🎉';
      msgColor = AppColors.primary;
      msgIcon = Icons.check_circle_rounded;
    } else {
      message = 'Casi, inténtalo de nuevo. Escucha la letra.';
      msgColor = AppColors.error;
      msgIcon = Icons.refresh_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Avatar de la tutora
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.primaryContainer, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                _correct == false
                    ? 'assets/images/ProfeTriste.jpeg'
                    : 'assets/images/ProfeFeliz.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              children: [
                Icon(msgIcon, color: msgColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: msgColor,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar (Repetir / Mic / Ayuda) ────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
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
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Repetir
              _BarBtn(
                icon: Icons.replay_rounded,
                onTap: () {
                  setState(() {
                    _selected = null;
                    _correct = null;
                  });
                },
              ),
              // Mic (acción principal)
              GestureDetector(
                onTap: _playLetter,
                child: Container(
                  width: 72,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.mic_rounded,
                      color: AppColors.onSecondaryContainer, size: 30),
                ),
              ),
              // Ayuda
              _BarBtn(
                icon: Icons.help_outline_rounded,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _BarBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        height: 56,
        child: Icon(icon, color: AppColors.onSurfaceVariant, size: 28),
      ),
    );
  }
}
