import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
 
// ─────────────────────────────────────────────
//  ESTADOS DEL AVATAR
// ─────────────────────────────────────────────
enum AvatarState { idle, talking, happy, celebrating }
 
class MaestraLuz extends StatefulWidget {
  final double size;
  const MaestraLuz({super.key, this.size = 200});
 
  @override
  State<MaestraLuz> createState() => MaestraLuzState();
}
 
class MaestraLuzState extends State<MaestraLuz>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  AvatarState _state = AvatarState.idle;
  final FlutterTts _tts = FlutterTts();
 
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
 
    _tts.setLanguage('es-MX');
    _tts.setSpeechRate(0.45);
 
    // Cuando TTS empieza → estado talking
    _tts.setStartHandler(() {
      if (mounted) setState(() => _state = AvatarState.talking);
    });
 
    // Cuando TTS termina → regresa a idle
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _state = AvatarState.idle);
    });
  }
 
  // ── API pública ────────────────────────────
  Future<void> hablar(String texto) async {
    await _tts.stop();
    await _tts.speak(texto);
  }
 
  void setEstado(AvatarState estado) {
    if (mounted) setState(() => _state = estado);
  }
 
  void celebrar() async {
    setState(() => _state = AvatarState.celebrating);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _state = AvatarState.idle);
  }
  // ──────────────────────────────────────────
 
  @override
  void dispose() {
    _ctrl.dispose();
    _tts.stop();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _MaestraPainter(
          t: _ctrl.value,
          state: _state,
        ),
      ),
    );
  }
}
 
// ─────────────────────────────────────────────
//  PAINTER — toda la lógica de dibujo
// ─────────────────────────────────────────────
class _MaestraPainter extends CustomPainter {
  final double t; // 0.0 → 1.0, ciclo continuo
  final AvatarState state;
 
  _MaestraPainter({required this.t, required this.state});
 
  // Paleta
  static const skin = Color(0xFFC8845A);
  static const skinDark = Color(0xFFA86A42);
  static const hair = Color(0xFF7A6A5A);
  static const hairDark = Color(0xFF5A4A3A);
  static const eyeColor = Color(0xFF3A2A1A);
  static const blouseBase = Color(0xFFF5E8D5);
  static const blousePattern = Color(0xFFC1440E);
  static const bgOuter = Color(0xFFC1440E);
  static const bgInner = Color(0xFFB8622A);
  static const teethColor = Color(0xFFF8F8F0);
  static const lipColor = Color(0xFFB85040);
  static const lipDark = Color(0xFF8B3020);
 
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final s = size.width / 200; // factor de escala
 
    final p = Paint()..isAntiAlias = true;
 
    // ── Clip circular ──────────────────────
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)));
 
    // Fondo
    p.color = bgInner;
    canvas.drawCircle(Offset(cx, cy), r, p);
 
    // Bounce para celebrating
    double yOff = 0;
    if (state == AvatarState.celebrating) {
      yOff = sin(t * 2 * pi) * 5 * s;
    }
    canvas.translate(0, yOff);
 
    _drawHairBack(canvas, s, cx, p);
    _drawFace(canvas, s, cx, p);
    _drawHairFront(canvas, s, cx, p);
    _drawEyebrows(canvas, s, cx, p);
    _drawEyes(canvas, s, cx, t, p);
    _drawNose(canvas, s, cx, p);
    _drawMouth(canvas, s, cx, t, p);
    _drawNeckBlouse(canvas, s, cx, size, p);
 
    if (state == AvatarState.celebrating) {
      _drawSparkles(canvas, s, cx, t, p);
    }
 
    canvas.restore();
 
    // Borde terracota
    p
      ..color = bgOuter
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * s;
    canvas.drawCircle(Offset(cx, cy), r - 2 * s, p);
    p.style = PaintingStyle.fill;
  }
 
  void _drawHairBack(Canvas canvas, double s, double cx, Paint p) {
    p.color = hairDark;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, 72 * s), width: 104 * s, height: 112 * s),
      p,
    );
    p.color = hair;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, 68 * s), width: 96 * s, height: 104 * s),
      p,
    );
  }
 
  void _drawFace(Canvas canvas, double s, double cx, Paint p) {
    p.color = skin;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, 105 * s), width: 84 * s, height: 100 * s),
      p,
    );
    // Mejillas si está feliz
    if (state == AvatarState.happy || state == AvatarState.celebrating) {
      p.color = const Color(0xFFE86060).withOpacity(0.25);
      canvas.drawOval(Rect.fromCenter(center: Offset(76 * s, 115 * s), width: 24 * s, height: 16 * s), p);
      canvas.drawOval(Rect.fromCenter(center: Offset(124 * s, 115 * s), width: 24 * s, height: 16 * s), p);
    }
  }
 
  void _drawHairFront(Canvas canvas, double s, double cx, Paint p) {
    p.color = hair;
    // Ondas frontales
    final path = Path()
      ..moveTo(58 * s, 72 * s)
      ..quadraticBezierTo(70 * s, 52 * s, cx, 50 * s)
      ..quadraticBezierTo(130 * s, 52 * s, 142 * s, 72 * s)
      ..quadraticBezierTo(130 * s, 62 * s, cx, 60 * s)
      ..quadraticBezierTo(70 * s, 62 * s, 58 * s, 72 * s);
    canvas.drawPath(path, p);
 
    // Lateral izquierdo
    final left = Path()
      ..moveTo(58 * s, 80 * s)
      ..quadraticBezierTo(52 * s, 100 * s, 60 * s, 130 * s)
      ..quadraticBezierTo(64 * s, 140 * s, 68 * s, 145 * s)
      ..quadraticBezierTo(62 * s, 120 * s, 64 * s, 95 * s)
      ..close();
    canvas.drawPath(left, p);
 
    // Lateral derecho
    final right = Path()
      ..moveTo(142 * s, 80 * s)
      ..quadraticBezierTo(148 * s, 100 * s, 140 * s, 130 * s)
      ..quadraticBezierTo(136 * s, 140 * s, 132 * s, 145 * s)
      ..quadraticBezierTo(138 * s, 120 * s, 136 * s, 95 * s)
      ..close();
    canvas.drawPath(right, p);
  }
 
  void _drawEyebrows(Canvas canvas, double s, double cx, Paint p) {
    final browY = (state == AvatarState.happy || state == AvatarState.celebrating) ? 88.0 : 90.0;
    p
      ..color = hairDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * s
      ..strokeCap = StrokeCap.round;
 
    final lb = Path()
      ..moveTo(78 * s, (browY + 1) * s)
      ..quadraticBezierTo(83 * s, (browY - 3) * s, 90 * s, browY * s);
    canvas.drawPath(lb, p);
 
    final rb = Path()
      ..moveTo(110 * s, browY * s)
      ..quadraticBezierTo(117 * s, (browY - 3) * s, 122 * s, (browY + 1) * s);
    canvas.drawPath(rb, p);
 
    p.style = PaintingStyle.fill;
  }
 
  void _drawEyes(Canvas canvas, double s, double cx, double t, Paint p) {
    // Parpadeo cada ~2 segundos
    final blinkCycle = t * 3; // 3 parpadeos por vuelta
    final blinkPhase = (blinkCycle % 1.0);
    double eyeOpen = 1.0;
    if (blinkPhase < 0.06) eyeOpen = 1.0 - (blinkPhase / 0.03).clamp(0, 1);
    else if (blinkPhase < 0.10) eyeOpen = ((blinkPhase - 0.06) / 0.04).clamp(0, 1);
 
    for (final ex in [84.0, 116.0]) {
      // Blanco
      p.color = Colors.white;
      canvas.drawOval(Rect.fromCenter(center: Offset(ex * s, 100 * s), width: 18 * s, height: 14 * s * eyeOpen), p);
 
      // Iris
      if (eyeOpen > 0.3) {
        p.color = eyeColor;
        canvas.drawCircle(Offset(ex * s, 100 * s), 5 * s * eyeOpen, p);
        p.color = Colors.white;
        canvas.drawCircle(Offset((ex - 2) * s, 98 * s), 1.5 * s, p);
      }
 
      // Párpado superior (piel)
      p.color = skin;
      final lid = Path()
        ..addOval(Rect.fromCenter(
          center: Offset(ex * s, (100 - 7 * eyeOpen) * s),
          width: 18 * s,
          height: 14 * s,
        ));
      canvas.drawPath(lid, p);
    }
  }
 
  void _drawNose(Canvas canvas, double s, double cx, Paint p) {
    p
      ..color = skinDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * s
      ..strokeCap = StrokeCap.round;
 
    final ln = Path()
      ..moveTo(97 * s, 108 * s)
      ..quadraticBezierTo(94 * s, 118 * s, 97 * s, 120 * s);
    canvas.drawPath(ln, p);
 
    final rn = Path()
      ..moveTo(103 * s, 108 * s)
      ..quadraticBezierTo(106 * s, 118 * s, 103 * s, 120 * s);
    canvas.drawPath(rn, p);
 
    p.style = PaintingStyle.fill;
  }
 
  void _drawMouth(Canvas canvas, double s, double cx, double t, Paint p) {
    final mouthY = 130.0;
    final mouthW = (state == AvatarState.happy || state == AvatarState.celebrating) ? 22.0 : 18.0;
    final smileAmt = (state == AvatarState.happy || state == AvatarState.celebrating) ? 8.0 : 4.0;
 
    // Apertura de boca (visemas)
    double openH = 0;
    if (state == AvatarState.talking) {
      openH = (sin(t * 2 * pi * 4) + 1) / 2 * 10; // oscila 0-10px
    }
 
    if (openH > 1) {
      // Boca abierta
      final mouth = Path()
        ..moveTo(cx - mouthW * s, mouthY * s)
        ..quadraticBezierTo(cx, (mouthY + smileAmt) * s, cx + mouthW * s, mouthY * s)
        ..quadraticBezierTo(cx + (mouthW + 3) * s, (mouthY + smileAmt + openH / 2) * s,
            cx + mouthW * s, (mouthY + openH + smileAmt) * s)
        ..quadraticBezierTo(cx, (mouthY + smileAmt + openH + 3) * s,
            cx - mouthW * s, (mouthY + openH + smileAmt) * s)
        ..quadraticBezierTo(cx - (mouthW + 3) * s, (mouthY + smileAmt + openH / 2) * s,
            cx - mouthW * s, mouthY * s)
        ..close();
 
      p.color = lipDark;
      canvas.drawPath(mouth, p);
 
      // Dientes
      if (openH > 3) {
        canvas.save();
        canvas.clipPath(mouth);
        p.color = teethColor;
        canvas.drawRect(
          Rect.fromLTWH(cx - (mouthW - 3) * s, (mouthY + 1) * s,
              (mouthW - 3) * 2 * s, (5 + openH * 0.5) * s),
          p,
        );
        canvas.restore();
      }
    } else {
      // Boca cerrada / sonrisa
      final smile = Path()
        ..moveTo(cx - mouthW * s, mouthY * s)
        ..quadraticBezierTo(cx, (mouthY + smileAmt) * s, cx + mouthW * s, mouthY * s)
        ..quadraticBezierTo(cx + (mouthW + 2) * s, (mouthY + smileAmt + 2) * s,
            cx + mouthW * s, mouthY * s)
        ..quadraticBezierTo(cx, (mouthY + smileAmt + 4) * s,
            cx - mouthW * s, mouthY * s)
        ..close();
      p.color = lipColor;
      canvas.drawPath(smile, p);
    }
 
    // Contorno labios
    p
      ..color = lipDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 * s;
    final outline = Path()
      ..moveTo(cx - mouthW * s, mouthY * s)
      ..quadraticBezierTo(cx, (mouthY + smileAmt) * s, cx + mouthW * s, mouthY * s);
    canvas.drawPath(outline, p);
    p.style = PaintingStyle.fill;
  }
 
  void _drawNeckBlouse(Canvas canvas, double s, double cx, Size size, Paint p) {
    p.color = skin;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, 150 * s), width: 36 * s, height: 30 * s),
      p,
    );
 
    final blouse = Path()
      ..moveTo(60 * s, 170 * s)
      ..quadraticBezierTo(cx, 155 * s, 140 * s, 170 * s)
      ..lineTo(148 * s, size.height)
      ..lineTo(52 * s, size.height)
      ..close();
    p.color = blouseBase;
    canvas.drawPath(blouse, p);
 
    // Bordado
    p.color = blousePattern;
    final dots = [
      [82.0, 176.0], [88.0, 172.0], [94.0, 178.0],
      [106.0, 172.0], [112.0, 176.0], [100.0, 180.0],
    ];
    for (final d in dots) {
      canvas.drawCircle(Offset(d[0] * s, d[1] * s), 1.8 * s, p);
    }
  }
 
  void _drawSparkles(Canvas canvas, double s, double cx, double t, Paint p) {
    p.color = const Color(0xFFF5C518);
    final positions = [[60.0, 65.0], [140.0, 65.0], [55.0, 90.0], [145.0, 85.0]];
    for (int i = 0; i < positions.length; i++) {
      final scale = 0.5 + 0.5 * (sin(t * 2 * pi + i) + 1) / 2;
      final sx = positions[i][0] * s;
      final sy = positions[i][1] * s;
      canvas.save();
      canvas.translate(sx, sy);
      canvas.scale(scale, scale);
      for (int a = 0; a < 4; a++) {
        canvas.save();
        canvas.rotate(a * pi / 2 + t * pi);
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 2 * s, height: 12 * s), p);
        canvas.restore();
      }
      canvas.restore();
    }
  }
 
  @override
  bool shouldRepaint(_MaestraPainter old) =>
      old.t != t || old.state != state;
}
