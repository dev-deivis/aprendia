import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../providers/progreso_provider.dart';

class ActividadSecundariaScreen extends StatefulWidget {
  final Map<String, String>? datos;
  const ActividadSecundariaScreen({super.key, this.datos});

  @override
  State<ActividadSecundariaScreen> createState() => _ActividadSecundariaScreenState();
}

class _ActividadSecundariaScreenState extends State<ActividadSecundariaScreen> {
  // ── Datos del tema ─────────────────────────────────────────────
  late final String _temaId;
  late final String _tipo;
  late final String _temaNombre;
  late final String _materiaNombre;
  late final String _materiaId;

  // ── Estado general ─────────────────────────────────────────────
  bool _completado = false;

  // ── Estado tipo lectura/opcion ─────────────────────────────────
  int? _seleccionado;
  bool _respondido = false;
  int _intentosFallidos = 0;

  // ── Estado tipo escritura ──────────────────────────────────────
  final _textoCtrl = TextEditingController();
  bool _revisado = false;
  bool _enviando = false;
  String? _retroalimentacion;

  @override
  void initState() {
    super.initState();
    final d = widget.datos ?? {};
    _temaId       = d['temaId'] ?? '';
    _tipo         = d['tipo'] ?? 'lectura';
    _temaNombre   = d['temaNombre'] ?? 'Actividad';
    _materiaNombre= d['materiaNombre'] ?? '';
    _materiaId    = d['materiaId'] ?? '';
    _textoCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textoCtrl.dispose();
    super.dispose();
  }

  // ── Mock content por tipo ──────────────────────────────────────
  static const _mockTexto =
      'En México, la educación es un derecho fundamental garantizado por la '
      'Constitución. El artículo 3° establece que toda persona tiene derecho '
      'a recibir educación de calidad. El Estado tiene la obligación de '
      'impartir educación preescolar, primaria, secundaria y media superior. '
      'La educación que imparte el Estado será laica, gratuita y obligatoria.';

  static const _preguntaLectura = '¿Qué establece el artículo 3° de la Constitución?';
  static const _opcionesLectura = [
    'Que solo los ciudadanos pueden estudiar',
    'El derecho de toda persona a recibir educación de calidad',  // correcta idx=1
    'Que la educación es opcional en México',
  ];

  static const _preguntaOpcion = '¿Cuál de las siguientes opciones describe mejor el concepto estudiado?';
  static const _opcionesOpcion = [
    'Es un proceso exclusivo de instituciones gubernamentales',
    'Es el resultado correcto según los principios del tema estudiado',  // correcta idx=1
    'No tiene aplicación en la vida cotidiana',
    'Solo aplica en contextos urbanos',
  ];
  static const _explicacionOpcion =
      'La opción B es correcta porque representa el principio central de este tema: '
      'los conceptos se aplican de manera universal y tienen relevancia en la vida diaria de todas las personas.';

  bool get _esOpcionCorrecta {
    if (_tipo == 'opcion') return _seleccionado == 1;
    return _seleccionado == 1; // lectura también correcta en idx=1
  }

  int get _totalPasos => _tipo == 'lectura' ? 2 : 1;
  int get _pasoActual  => _completado ? _totalPasos : 1;

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
                child: _buildContenido(context),
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
            onTap: () => _confirmarSalida(context),
            child: const Icon(Icons.arrow_back_rounded,
                color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_materiaNombre · $_temaNombre',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Paso $_pasoActual de $_totalPasos',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Preguntar al tutor
          GestureDetector(
            onTap: () => context.push(AppRoutes.secundariaChat, extra: {
              'materiaId': _materiaId,
              'materiaNombre': _materiaNombre,
              'temaId': _temaId,
              'temaNombre': _temaNombre,
            }),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_rounded,
                  color: AppColors.onSecondaryContainer, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenido(BuildContext context) {
    if (_completado) return _buildCelebracion(context);

    return switch (_tipo) {
      'escritura' => _buildEscritura(context),
      'opcion'    => _buildOpcion(context),
      _           => _buildLectura(context),
    };
  }

  // ── TIPO LECTURA ───────────────────────────────────────────────
  Widget _buildLectura(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texto
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryFixed.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryFixed),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lee con atención:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _mockTexto,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.65,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Pregunta
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Text(
            _preguntaLectura,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Opciones
        ..._opcionesLectura.asMap().entries.map((e) =>
            _buildOpcionCard(e.key, e.value, maxOpciones: 3)),
        const SizedBox(height: 16),
        if (_respondido) _buildFeedbackLectura(context),
      ],
    );
  }

  Widget _buildFeedbackLectura(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _esOpcionCorrecta
                ? AppColors.primaryFixed.withValues(alpha: 0.3)
                : AppColors.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                _esOpcionCorrecta
                    ? Icons.check_circle_rounded
                    : Icons.info_rounded,
                color: _esOpcionCorrecta ? AppColors.primary : AppColors.error,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _esOpcionCorrecta
                      ? '¡Correcto! Entendiste bien el texto. 🎉'
                      : _intentosFallidos >= 2
                          ? 'La respuesta correcta es la opción B. La Constitución garantiza educación de calidad para todos.'
                          : 'No es correcto. Vuelve a leer el texto con atención. 💛',
                  style: TextStyle(
                    fontSize: 14,
                    color: _esOpcionCorrecta ? AppColors.primary : AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_esOpcionCorrecta)
          _buildBtnSiguiente(context)
        else if (_intentosFallidos < 2)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => setState(() {
                _seleccionado = null;
                _respondido = false;
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryContainer,
                foregroundColor: AppColors.onSecondaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Intentar de nuevo',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          )
        else
          _buildBtnSiguiente(context),
      ],
    );
  }

  // ── TIPO OPCION MÚLTIPLE ───────────────────────────────────────
  Widget _buildOpcion(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.secondaryFixed.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondaryFixed, width: 1.5),
          ),
          child: Text(
            _preguntaOpcion,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ..._opcionesOpcion.asMap().entries.map((e) =>
            _buildOpcionCard(e.key, e.value, maxOpciones: 4)),
        const SizedBox(height: 16),
        if (_seleccionado != null && !_respondido)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => setState(() {
                _respondido = true;
                if (!_esOpcionCorrecta) _intentosFallidos++;
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Comprobar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        if (_respondido) ...[
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _esOpcionCorrecta
                  ? AppColors.primaryFixed.withValues(alpha: 0.3)
                  : AppColors.secondaryFixed.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _esOpcionCorrecta
                    ? AppColors.primaryFixed
                    : AppColors.secondaryFixed,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _esOpcionCorrecta ? '¡Excelente! ✅' : 'Casi, sigue adelante 💛',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _esOpcionCorrecta ? AppColors.primary : AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  _explicacionOpcion,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildBtnSiguiente(context),
        ],
      ],
    );
  }

  // ── TIPO ESCRITURA ─────────────────────────────────────────────
  Widget _buildEscritura(BuildContext context) {
    final palabras = _textoCtrl.text.trim().isEmpty
        ? 0
        : _textoCtrl.text.trim().split(RegExp(r'\s+')).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instrucción del avatar
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
                  'Escribe un párrafo con tus propias palabras sobre lo que aprendiste en este tema. '
                  'No hay respuestas incorrectas — lo importante es expresar tus ideas.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Área de texto
        TextField(
          controller: _textoCtrl,
          maxLines: 8,
          enabled: !_revisado,
          decoration: InputDecoration(
            hintText: 'Escribe aquí tu párrafo...',
            hintStyle: const TextStyle(color: AppColors.outline),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.surfaceVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.surfaceVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.onSurface),
        ),
        const SizedBox(height: 8),
        // Contador
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.text_fields_rounded,
              size: 14,
              color: palabras >= 20 ? AppColors.primary : AppColors.outline,
            ),
            const SizedBox(width: 4),
            Text(
              '$palabras palabras${palabras < 20 ? " (mínimo 20)" : " ✓"}',
              style: TextStyle(
                fontSize: 12,
                color: palabras >= 20 ? AppColors.primary : AppColors.outline,
                fontWeight: palabras >= 20 ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Retroalimentación
        if (_retroalimentacion != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryFixed),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Revisión de AprendIA 📝',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _retroalimentacion!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurface,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Botones
        if (!_revisado)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: palabras < 20 || _enviando
                  ? null
                  : () => _revisarTexto(),
              icon: _enviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(_enviando ? 'Revisando...' : 'Revisar con AprendIA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.surfaceContainerHighest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          )
        else
          _buildBtnSiguiente(context),
      ],
    );
  }

  Future<void> _revisarTexto() async {
    setState(() => _enviando = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _enviando = false;
      _revisado = true;
      _retroalimentacion =
          '¡Muy buen trabajo! Tu párrafo expresa ideas claras y está bien organizado. '
          'Noto que usas tus propias palabras para explicar el tema, lo cual demuestra '
          'que lo entendiste. Para hacerlo aún mejor, podrías agregar un ejemplo concreto '
          'de tu experiencia cotidiana. ¡Sigue así! 💛';
    });
  }

  // ── Helpers compartidos ────────────────────────────────────────
  Widget _buildOpcionCard(int i, String texto, {required int maxOpciones}) {
    final selected = _seleccionado == i;
    final resaltarCorrecta = _respondido && !_esOpcionCorrecta && i == 1;

    Color borderColor = AppColors.surfaceVariant;
    Color bgColor = AppColors.surfaceContainerLowest;

    if (selected && !_respondido) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primaryFixed.withValues(alpha: 0.3);
    } else if (_respondido && selected && _esOpcionCorrecta) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primaryFixed.withValues(alpha: 0.3);
    } else if (_respondido && selected && !_esOpcionCorrecta) {
      borderColor = AppColors.error;
      bgColor = AppColors.errorContainer.withValues(alpha: 0.2);
    } else if (resaltarCorrecta || (_intentosFallidos >= 2 && i == 1)) {
      borderColor = AppColors.primaryFixed;
      bgColor = AppColors.primaryFixed.withValues(alpha: 0.2);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: _respondido
            ? null
            : () => setState(() => _seleccionado = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.8),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: selected && !_respondido
                      ? AppColors.primary
                      : AppColors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + i),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: selected && !_respondido
                          ? Colors.white
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBtnSiguiente(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _completarActividad(context),
        icon: const Icon(Icons.arrow_forward_rounded),
        label: const Text('Siguiente',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  void _completarActividad(BuildContext context) {
    if (_temaId.isNotEmpty) {
      context.read<ProgresoProvider>().completarTema(_temaId);
    }
    setState(() => _completado = true);
  }

  Widget _buildCelebracion(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            const Text(
              '¡Tema completado!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _temaNombre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _mostrarDialogoEvaluacion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: const Text('Continuar'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: const Text('Volver a la materia'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoEvaluacion() async {
    final evaluar = await showDialog<bool>(
      context: context,
      builder: (dlg) => AlertDialog(
        title: const Text('¿Lista para la evaluación? 📝'),
        content: Text(
          '¿Quieres poner a prueba lo que aprendiste en "$_temaNombre"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlg).pop(false),
            child: const Text('Después'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dlg).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, evaluarme'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (evaluar == true) {
      context.pushReplacement(AppRoutes.secundariaEvaluacion, extra: {
        'temaId': _temaId,
        'temaNombre': _temaNombre,
        'materiaId': _materiaId,
        'materiaNombre': _materiaNombre,
      });
    } else {
      context.pop();
    }
  }

  Future<void> _confirmarSalida(BuildContext context) async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Quieres salir?'),
        content: const Text('Tu progreso en esta actividad se guarda. Puedes continuar después.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Quedarme'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (salir == true && context.mounted) context.pop();
  }
}
