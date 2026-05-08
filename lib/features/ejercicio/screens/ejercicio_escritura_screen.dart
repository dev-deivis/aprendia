import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class EjercicioEscrituraScreen extends StatefulWidget {
  final String letter;

  const EjercicioEscrituraScreen({super.key, this.letter = 'A'});

  @override
  State<EjercicioEscrituraScreen> createState() =>
      _EjercicioEscrituraScreenState();
}

class _EjercicioEscrituraScreenState extends State<EjercicioEscrituraScreen> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentStroke = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentStroke = [..._currentStroke, details.localPosition];
    });
  }

  void _onPanEnd(DragEndDetails _) {
    if (_currentStroke.isEmpty) return;
    setState(() {
      _strokes.add(List.from(_currentStroke));
      _currentStroke = [];
    });
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAvatarGuidance(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCanvas(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        showLabels: true,
        onReplay: () {},
        onMic: () {},
        onHelp: () {},
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: AppColors.surface,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AprendIA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarGuidance() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryFixed, width: 2),
              color: AppColors.primaryContainer,
            ),
            child: const Icon(
              Icons.face_rounded,
              color: AppColors.onPrimaryContainer,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: AppColors.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.onSurface,
                    height: 1.45,
                  ),
                  children: [
                    const TextSpan(
                        text: '¡Excelente! Ahora vamos a trazar la letra '),
                    TextSpan(
                      text: widget.letter,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const TextSpan(
                        text: '. Inténtalo en el cuadro de abajo.'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth;
        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Container(
            width: side,
            height: side,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: CustomPaint(
              size: Size(side, side),
              painter: _WritingCanvasPainter(
                strokes: _strokes,
                currentStroke: _currentStroke,
                traceLetter: widget.letter,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _clearCanvas,
              icon: const Icon(Icons.backspace_rounded),
              label: const Text('Borrar todo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onSurfaceVariant,
                side: const BorderSide(color: AppColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _strokes.isEmpty ? null : _onComprobar,
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Comprobar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryContainer,
                foregroundColor: AppColors.onSecondaryContainer,
                disabledBackgroundColor: AppColors.surfaceContainerHighest,
                disabledForegroundColor: AppColors.outline,
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onComprobar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Muy bien! Sigue practicando.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _WritingCanvasPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final String traceLetter;

  const _WritingCanvasPainter({
    required this.strokes,
    required this.currentStroke,
    required this.traceLetter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGuidelines(canvas, size);
    _drawTraceLetter(canvas, size);
    _drawStrokes(canvas);
  }

  void _drawGuidelines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryFixedDim.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const lines = 4;
    final spacing = size.height / (lines + 1);
    for (int i = 1; i <= lines; i++) {
      final y = spacing * i;
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, y), Offset(x + 8, y), paint);
        x += 16;
      }
    }
  }

  void _drawTraceLetter(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: traceLetter,
        style: TextStyle(
          fontSize: size.width * 0.68,
          fontWeight: FontWeight.w300,
          color: AppColors.surfaceDim,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void _drawStrokes(Canvas canvas) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void drawStroke(List<Offset> stroke) {
      if (stroke.length < 2) return;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    for (final stroke in strokes) {
      drawStroke(stroke);
    }
    drawStroke(currentStroke);
  }

  @override
  bool shouldRepaint(_WritingCanvasPainter old) =>
      old.strokes != strokes || old.currentStroke != currentStroke;
}
