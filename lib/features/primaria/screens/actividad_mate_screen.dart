import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../providers/progreso_provider.dart';

class ActividadMateScreen extends StatefulWidget {
  final String? temaId;
  const ActividadMateScreen({super.key, this.temaId});

  @override
  State<ActividadMateScreen> createState() => _ActividadMateScreenState();
}

class _ActividadMateScreenState extends State<ActividadMateScreen> {
  String _entrada = '';
  int _intentos = 0;
  bool? _correcto; // null=sin respuesta, true=ok, false=incorrecto
  bool _mostrarRespuesta = false;

  static const int _respuestaCorrecta = 8;
  static const int _maxIntentos = 3;

  void _presionarTecla(String key) {
    if (_correcto == true || _mostrarRespuesta) return;
    setState(() {
      if (key == '⌫') {
        if (_entrada.isNotEmpty) _entrada = _entrada.substring(0, _entrada.length - 1);
      } else if (key == 'C') {
        _entrada = '';
      } else if (_entrada.length < 3) {
        _entrada += key;
      }
    });
  }

  void _comprobar() {
    if (_entrada.isEmpty || _correcto == true) return;
    final respuesta = int.tryParse(_entrada) ?? -1;
    final ok = respuesta == _respuestaCorrecta;
    setState(() {
      _intentos++;
      _correcto = ok;
      if (!ok && _intentos >= _maxIntentos) _mostrarRespuesta = true;
    });
  }

  void _reintentar() {
    setState(() {
      _entrada = '';
      _correcto = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProblema(),
                    const SizedBox(height: 24),
                    _buildEntrada(),
                    const SizedBox(height: 20),
                    if (_correcto != null || _mostrarRespuesta)
                      _buildFeedback(context)
                    else ...[
                      _buildNumpad(),
                      const SizedBox(height: 16),
                      _buildComprobarBtn(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.surface,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_rounded,
                color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Matemáticas · Suma y resta',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.push(AppRoutes.tutor),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: AppColors.onSecondaryContainer, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblema() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryFixed.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryFixed, width: 1.5),
      ),
      child: Column(
        children: [
          const Text('🍎', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          const Text(
            'María tiene 15 manzanas y le da 7 a su vecino.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              height: 1.5,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '¿Cuántas manzanas le quedan?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '15 − 7 = ?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntrada() {
    return Container(
      width: 180,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _correcto == true
              ? AppColors.primary
              : _correcto == false
                  ? AppColors.error
                  : AppColors.outlineVariant,
          width: 2.5,
        ),
      ),
      child: Center(
        child: Text(
          _entrada.isEmpty ? '?' : _entrada,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: _entrada.isEmpty
                ? AppColors.outlineVariant
                : _correcto == true
                    ? AppColors.primary
                    : AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    const keys = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['C', '0', '⌫'],
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.6,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        for (final row in keys)
          for (final key in row)
            _NumKey(
              label: key,
              isAction: key == '⌫' || key == 'C',
              onTap: () => _presionarTecla(key),
            ),
      ],
    );
  }

  Widget _buildComprobarBtn() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _entrada.isEmpty ? null : _comprobar,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Text(
          _intentos > 0 && _correcto == false ? 'Intentar de nuevo ($_intentos/$_maxIntentos)' : 'Comprobar',
        ),
      ),
    );
  }

  Widget _buildFeedback(BuildContext context) {
    if (_correcto == true) {
      return Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          const Text(
            '¡Correcto! 15 − 7 = 8',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                if (widget.temaId != null) {
                  context.read<ProgresoProvider>().completarTema(widget.temaId!);
                }
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: const Text('Siguiente actividad'),
            ),
          ),
        ],
      );
    }

    // Incorrecto (con o sin respuesta mostrada)
    return Column(
      children: [
        ClipOval(
          child: Image.asset('assets/images/ProfeTriste.jpeg',
              width: 80, height: 80, fit: BoxFit.cover),
        ),
        const SizedBox(height: 12),
        Text(
          _mostrarRespuesta
              ? 'La respuesta es 8.\n15 − 7 = 8\nQuita 7 de 15 y quedan 8.'
              : 'No es correcto, intenta de nuevo.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        if (!_mostrarRespuesta)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _reintentar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryContainer,
                foregroundColor: AppColors.onSecondaryContainer,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: const Text('Intentar de nuevo'),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: const Text('Volver a Materias'),
            ),
          ),
      ],
    );
  }
}

class _NumKey extends StatelessWidget {
  final String label;
  final bool isAction;
  final VoidCallback onTap;

  const _NumKey({
    required this.label,
    required this.isAction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isAction ? AppColors.surfaceContainer : AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isAction ? AppColors.onSurfaceVariant : AppColors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
