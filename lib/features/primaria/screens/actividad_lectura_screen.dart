import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../providers/progreso_provider.dart';

enum _Estado { leer, responder, retroalimentacion, completado }

class ActividadLecturaScreen extends StatefulWidget {
  final String? temaId;
  const ActividadLecturaScreen({super.key, this.temaId});

  @override
  State<ActividadLecturaScreen> createState() => _ActividadLecturaScreenState();
}

class _ActividadLecturaScreenState extends State<ActividadLecturaScreen> {
  _Estado _estado = _Estado.leer;
  int? _respuestaSeleccionada;
  bool get _correcto => _respuestaSeleccionada == 1; // índice correcto

  static const _texto =
      'El agua es esencial para la vida. Todos los seres vivos necesitan agua '
      'para sobrevivir. Nuestro cuerpo está compuesto de más del 60% de agua. '
      'Los médicos recomiendan tomar entre 6 y 8 vasos de agua al día para '
      'mantenernos sanos y con energía.';

  static const _pregunta = '¿Cuántos vasos de agua debemos tomar al día?';

  static const _opciones = [
    '2 a 4 vasos',
    '6 a 8 vasos',
    '10 a 12 vasos',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildContent(context),
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
              'El agua y la vida',
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

  Widget _buildContent(BuildContext context) {
    switch (_estado) {
      case _Estado.leer:
        return _buildLeer(context);
      case _Estado.responder:
        return _buildResponder(context);
      case _Estado.retroalimentacion:
        return _buildRetroalimentacion(context);
      case _Estado.completado:
        return _buildCompletado(context);
    }
  }

  Widget _buildLeer(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('leer'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ilustración
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('💧', style: TextStyle(fontSize: 72)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Lee con atención:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _texto,
              style: const TextStyle(
                fontSize: 18,
                height: 1.7,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _estado = _Estado.responder),
              icon: const Icon(Icons.quiz_rounded),
              label: const Text('Responder pregunta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponder(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('responder'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset('assets/images/ProfeFeliz.jpeg',
                      width: 48, height: 48, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    _pregunta,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ..._opciones.asMap().entries.map((e) {
            final i = e.key;
            final txt = e.value;
            final selected = _respuestaSeleccionada == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _respuestaSeleccionada = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryFixed
                        : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      width: selected ? 2.5 : 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + i),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: selected ? Colors.white : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        txt,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: selected ? AppColors.primary : AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _respuestaSeleccionada == null
                  ? null
                  : () => setState(() => _estado = _Estado.retroalimentacion),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryContainer,
                foregroundColor: AppColors.onSecondaryContainer,
                disabledBackgroundColor: AppColors.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: const Text('Comprobar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroalimentacion(BuildContext context) {
    return Center(
      key: const ValueKey('retro'),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _correcto ? '¡Excelente! 🎉' : 'Casi, inténtalo de nuevo',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: _correcto ? AppColors.primary : AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            ClipOval(
              child: Image.asset(
                _correcto
                    ? 'assets/images/ProfeFeliz.jpeg'
                    : 'assets/images/ProfeTriste.jpeg',
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _correcto
                  ? 'La respuesta correcta es:\n"6 a 8 vasos de agua al día".'
                  : 'Vuelve a leer el texto con atención.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _correcto
                    ? () => setState(() => _estado = _Estado.completado)
                    : () => setState(() {
                          _respuestaSeleccionada = null;
                          _estado = _Estado.responder;
                        }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _correcto ? AppColors.primary : AppColors.secondaryContainer,
                  foregroundColor: _correcto ? Colors.white : AppColors.onSecondaryContainer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: Text(_correcto ? 'Siguiente actividad' : 'Intentar de nuevo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletado(BuildContext context) {
    return Center(
      key: const ValueKey('completado'),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            const Text(
              '¡Tema completado!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ganaste una estrella por completar\n"El agua y la vida"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 56,
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
                child: const Text('Volver a Materias'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
