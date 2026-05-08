import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../providers/progreso_provider.dart';

class EvaluacionSecundariaScreen extends StatefulWidget {
  final Map<String, String>? datos;
  const EvaluacionSecundariaScreen({super.key, this.datos});

  @override
  State<EvaluacionSecundariaScreen> createState() =>
      _EvaluacionSecundariaScreenState();
}

class _EvaluacionSecundariaScreenState
    extends State<EvaluacionSecundariaScreen> {
  int _preguntaActual = 0;
  int? _seleccion;
  bool _respondido = false;
  int _correctas = 0;
  bool _terminado = false;

  String get _temaNombre =>
      widget.datos?['temaNombre'] ?? 'el tema';
  String get _materiaNombre =>
      widget.datos?['materiaNombre'] ?? 'la materia';

  late final List<_Pregunta> _preguntas = _preguntasParaTema(_temaNombre);

  @override
  Widget build(BuildContext context) {
    if (_terminado) return _buildResultado(context);

    final p = _preguntas[_preguntaActual];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final salir = await _confirmarSalida(context);
        if (salir == true && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF9F6),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _buildAppBar(context),
        ),
        body: Column(
          children: [
            _buildProgreso(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPregunta(p),
                    const SizedBox(height: 20),
                    ..._buildOpciones(p),
                    if (_respondido) ...[
                      const SizedBox(height: 20),
                      _buildExplicacion(p),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _siguiente,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            _preguntaActual < _preguntas.length - 1
                                ? 'Siguiente pregunta'
                                : 'Ver resultado',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
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

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                final salir = await _confirmarSalida(context);
                if (salir == true && context.mounted) context.pop();
              },
              child: const Icon(Icons.close_rounded,
                  color: AppColors.onSurfaceVariant, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Evaluación · $_materiaNombre',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    _temaNombre,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgreso() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pregunta ${_preguntaActual + 1} de ${_preguntas.length}',
            style: const TextStyle(
                fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_preguntaActual + 1) / _preguntas.length,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPregunta(_Pregunta p) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primaryFixed, width: 1.5),
      ),
      child: Text(
        p.enunciado,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
          height: 1.5,
        ),
      ),
    );
  }

  List<Widget> _buildOpciones(_Pregunta p) {
    return List.generate(p.opciones.length, (i) {
      Color bg = AppColors.surfaceContainerLowest;
      Color border = AppColors.surfaceContainerHighest;
      Widget? trailing;

      if (_respondido) {
        if (i == p.correcta) {
          bg = const Color(0xFFE8F5E9);
          border = Colors.green;
          trailing = const Icon(Icons.check_circle_rounded,
              color: Colors.green, size: 20);
        } else if (i == _seleccion && i != p.correcta) {
          bg = AppColors.errorContainer;
          border = AppColors.error;
          trailing = const Icon(Icons.cancel_rounded,
              color: AppColors.error, size: 20);
        }
      } else if (_seleccion == i) {
        bg = AppColors.primaryFixed.withValues(alpha: 0.4);
        border = AppColors.primary;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: _respondido ? null : () => _seleccionar(i),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _seleccion == i && !_respondido
                          ? AppColors.primary
                          : AppColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + i),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _seleccion == i && !_respondido
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p.opciones[i],
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.onSurface),
                    ),
                  ),
                  if (trailing != null) trailing,
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildExplicacion(_Pregunta p) {
    final correcto = _seleccion == p.correcta;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: correcto
            ? const Color(0xFFE8F5E9)
            : AppColors.secondaryFixed.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: correcto ? Colors.green : AppColors.secondaryContainer,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correcto ? Icons.star_rounded : Icons.lightbulb_rounded,
            color: correcto ? Colors.green : AppColors.secondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  correcto ? '¡Correcto!' : 'Casi, sigue intentando',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: correcto ? Colors.green : AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.explicacion,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurface,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultado(BuildContext context) {
    final estrellas = _estrellas(_correctas, _preguntas.length);
    final msg = switch (estrellas) {
      4 => '¡Excelente! Dominaste el tema.',
      3 => '¡Muy bien! Aprendiste lo esencial.',
      2 => 'Vas bien. Un poco más de práctica.',
      _ => 'No te rindas. Repasa y vuelve a intentarlo.',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => Icon(
                  i < estrellas ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: i < estrellas
                      ? AppColors.secondaryContainer
                      : AppColors.outline,
                  size: 44,
                )),
              ),
              const SizedBox(height: 24),
              Text(
                '$_correctas de ${_preguntas.length} correctas',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.secundariaHome),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Volver al inicio',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (widget.datos != null) {
                      context.push(AppRoutes.secundariaChat,
                          extra: widget.datos);
                    } else {
                      context.push(AppRoutes.secundariaChat);
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_rounded),
                  label: const Text('Preguntar al avatar',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              if (estrellas < 3) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton.icon(
                    onPressed: () {
                      if (widget.datos != null) {
                        context.push(AppRoutes.secundariaActividad,
                            extra: widget.datos);
                      } else {
                        context.pop();
                      }
                    },
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Repasar el tema',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _seleccionar(int i) {
    setState(() => _seleccion = i);
  }

  void _siguiente() {
    if (!_respondido) {
      if (_seleccion == null) return;
      final correcto = _seleccion == _preguntas[_preguntaActual].correcta;
      setState(() {
        _respondido = true;
        if (correcto) _correctas++;
      });
      return;
    }

    if (_preguntaActual < _preguntas.length - 1) {
      setState(() {
        _preguntaActual++;
        _seleccion = null;
        _respondido = false;
      });
    } else {
      // Marcar tema en progreso al terminar si no había sido marcado
      final datos = widget.datos;
      if (datos != null) {
        final temaId = datos['temaId'];
        if (temaId != null) {
          context.read<ProgresoProvider>().completarTema(temaId);
        }
      }
      setState(() => _terminado = true);
    }
  }

  Future<bool?> _confirmarSalida(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Salir de la evaluación?'),
          content:
              const Text('Tu progreso en esta evaluación no se guardará.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Continuar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Salir'),
            ),
          ],
        ),
      );

  int _estrellas(int correctas, int total) {
    final pct = correctas / total;
    if (pct >= 1.0) return 4;
    if (pct >= 0.75) return 3;
    if (pct >= 0.5) return 2;
    return 1;
  }

  List<_Pregunta> _preguntasParaTema(String tema) {
    return [
      _Pregunta(
        enunciado: '¿Cuál es la idea principal de "$tema"?',
        opciones: [
          'Memorizar datos sin entender el contexto',
          'Comprender los conceptos y aplicarlos en la vida diaria',
          'Resolver ejercicios lo más rápido posible',
          'Copiar la información del libro',
        ],
        correcta: 1,
        explicacion:
            'El aprendizaje significativo se logra cuando comprendemos los conceptos y los conectamos con nuestra vida.',
      ),
      _Pregunta(
        enunciado: 'Al estudiar "$tema", ¿qué estrategia es más efectiva?',
        opciones: [
          'Leer una sola vez y pasar al siguiente tema',
          'Tomar notas y hacer preguntas',
          'Esperar a que alguien te lo explique todo',
          'Saltarse las partes difíciles',
        ],
        correcta: 1,
        explicacion:
            'Tomar notas y formular preguntas activa la memoria y mejora la comprensión del tema.',
      ),
      _Pregunta(
        enunciado:
            '¿Por qué es importante aprender "$tema" en la secundaria?',
        opciones: [
          'Solo para pasar el examen',
          'Porque lo pide el maestro',
          'Para desarrollar habilidades útiles en la vida y el trabajo',
          'No tiene utilidad práctica',
        ],
        correcta: 2,
        explicacion:
            'La educación secundaria forma las bases para el desarrollo personal, laboral y ciudadano.',
      ),
      _Pregunta(
        enunciado:
            '¿Qué hacer cuando algo de "$tema" resulta difícil de entender?',
        opciones: [
          'Rendirse y pasar al siguiente tema',
          'Preguntar al tutor y buscar más ejemplos',
          'Ignorar esa parte del tema',
          'Esperar a que desaparezca la duda',
        ],
        correcta: 1,
        explicacion:
            'Preguntar y buscar ejemplos son las mejores estrategias ante una dificultad de aprendizaje.',
      ),
    ];
  }
}

class _Pregunta {
  final String enunciado;
  final List<String> opciones;
  final int correcta;
  final String explicacion;

  const _Pregunta({
    required this.enunciado,
    required this.opciones,
    required this.correcta,
    required this.explicacion,
  });
}
