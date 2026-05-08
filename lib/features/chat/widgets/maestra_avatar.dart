import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum AvatarState { idle, talking, happy, celebrating }

class XoloAvatar extends StatefulWidget {
  final double size;
  const XoloAvatar({super.key, this.size = 200});

  @override
  State<XoloAvatar> createState() => XoloAvatarState();
}

class XoloAvatarState extends State<XoloAvatar> with TickerProviderStateMixin {
  late final AnimationController _idleCtrl;   // flotación suave
  late final AnimationController _faceCtrl;   // parpadeo + boca
  late final AnimationController _celebCtrl;  // bounce al celebrar

  AvatarState _state = AvatarState.idle;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();

    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _faceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(); // siempre activo para parpadeo

    _celebCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _initTts();
    _tts.setStartHandler(() {
      if (!mounted) return;
      setState(() => _state = AvatarState.talking);
    });
    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _state = AvatarState.idle);
    });
  }

  Future<void> _initTts() async {
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(0.70); // grave para voz masculina

    // Prueba voces masculinas conocidas de Google TTS en orden
    const maleVoices = [
      {'name': 'es-us-x-esm-local',  'locale': 'es-US'},
      {'name': 'es-mx-x-esm-local',  'locale': 'es-MX'},
      {'name': 'es-es-x-eee-local',  'locale': 'es-ES'},
      {'name': 'es-us-x-esc-local',  'locale': 'es-US'},
    ];

    bool voiceSet = false;
    for (final v in maleVoices) {
      try {
        final result = await _tts.setVoice(v);
        if (result == 1) { voiceSet = true; break; }
      } catch (_) {}
    }

    // Si ninguna voz masculina funcionó, usa es-MX con pitch bajo
    if (!voiceSet) await _tts.setLanguage('es-MX');
  }

  Future<void> hablar(String texto) async {
    await _tts.stop();
    await _tts.speak(texto);
  }

  void setEstado(AvatarState estado) {
    if (mounted) setState(() => _state = estado);
  }

  void celebrar() async {
    setState(() => _state = AvatarState.celebrating);
    _celebCtrl.repeat(reverse: true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    _celebCtrl..stop()..reset();
    setState(() => _state = AvatarState.idle);
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    _faceCtrl.dispose();
    _celebCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_idleCtrl, _faceCtrl, _celebCtrl]),
      builder: (context, _) {
        double yOff  = sin(_idleCtrl.value * pi) * 4.0;
        double scale = 1.0;

        switch (_state) {
          case AvatarState.happy:
            scale = 1.05;
          case AvatarState.celebrating:
            yOff  = -sin(_celebCtrl.value * pi) * 12.0;
            scale = 1.0 + sin(_celebCtrl.value * pi) * 0.06;
          case AvatarState.idle:
          case AvatarState.talking:
            break;
        }

        return Transform.translate(
          offset: Offset(0, yOff),
          child: Transform.scale(
            scale: scale,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ── Imagen PNG base ─────────────────────────
                  ClipOval(
                    child: Image.asset(
                      'assets/images/xolo.png',
                      width:  widget.size,
                      height: widget.size,
                      fit:    BoxFit.cover,
                      alignment: const Alignment(0, -0.6),
                    ),
                  ),

                  // ── Ojos y boca animados ─────────────────────
                  CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _FaceOverlayPainter(
                      t:     _faceCtrl.value,
                      state: _state,
                    ),
                  ),

                  // ── Brillo dorado en happy/celebrating ───────
                  if (_state == AvatarState.happy ||
                      _state == AvatarState.celebrating)
                    Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF5C842).withValues(alpha: 0.45),
                            blurRadius: 22,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),

                  // ── Destellos al celebrar ────────────────────
                  if (_state == AvatarState.celebrating)
                    CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _SparklesPainter(t: _celebCtrl.value),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Overlay de cara: parpadeo + boca ──────────────────────────────────────
//
// AJUSTA estas constantes si los ojos/boca no quedan sobre el PNG:
//   _eyeY    → qué tan abajo están los ojos (fracción de size)
//   _eyeXOff → separación horizontal de cada ojo desde el centro
//   _mouthY  → altura de la boca
// ──────────────────────────────────────────────────────────────────────────
class _FaceOverlayPainter extends CustomPainter {
  final double t;
  final AvatarState state;
  _FaceOverlayPainter({required this.t, required this.state});

  // ── Posiciones (fracción de size) ─── ajustar según el PNG ───────────
  static const double _eyeY     = 0.41;  // centro vertical de ojos
  static const double _eyeXOff  = 0.155; // distancia horizontal desde centro
  static const double _eyeW     = 0.120; // ancho de cada ojo
  static const double _eyeH     = 0.075; // alto de cada ojo (abierto)
  static const double _mouthY   = 0.725; // centro vertical de boca
  static const double _mouthW   = 0.220; // ancho de boca
  static const double _mouthH   = 0.090; // alto máximo al hablar

  // Colores aproximados al PNG — ajustar si no coinciden
  static const _skinColor  = Color(0xFFBF7A48);  // tono de piel para párpados
  static const _mouthOpen  = Color(0xFF3A1A0A);  // interior boca abierta
  static const _lipColor   = Color(0xFF9A3828);  // labios
  static const _teethColor = Color(0xFFF0EDE0);  // dientes

  @override
  void paint(Canvas canvas, Size size) {
    final w  = size.width;
    final cx = w / 2;
    final p  = Paint()..isAntiAlias = true;

    _drawBlink(canvas, cx, size, p);
    _drawMouth(canvas, cx, size, p);
  }

  // ── Parpadeo ─────────────────────────────────────────────────────────
  void _drawBlink(Canvas canvas, double cx, Size size, Paint p) {
    // Ciclo: 3 parpadeos por vuelta del faceCtrl (300ms * 3 = 900ms ≈ cada 3s real)
    // _faceCtrl siempre corre (repeat), damos 1 parpadeo cada ~4 ciclos
    final cycle = (t * 4) % 1.0;
    double lidFraction = 0.0; // 0=abierto, 1=cerrado

    if (cycle < 0.04) {
      lidFraction = (cycle / 0.02).clamp(0.0, 1.0);
    } else if (cycle < 0.08) {
      lidFraction = ((0.08 - cycle) / 0.04).clamp(0.0, 1.0);
    }

    if (lidFraction < 0.01) return; // ojo abierto — no pintar nada

    final eyeH = size.height * _eyeH;
    final eyeW = size.width  * _eyeW;
    final eyeY = size.height * _eyeY;

    p.color = _skinColor;
    for (final xOff in [-_eyeXOff, _eyeXOff]) {
      final ex = cx + size.width * xOff;
      // Párpado: rectángulo superior que cubre el ojo proporcionalmente
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(ex, eyeY - eyeH * (1 - lidFraction) * 0.5),
          width:  eyeW,
          height: eyeH * lidFraction,
        ),
        p,
      );
    }
  }

  // ── Boca ─────────────────────────────────────────────────────────────
  void _drawMouth(Canvas canvas, double cx, Size size, Paint p) {
    final mW  = size.width  * _mouthW / 2;
    final mY  = size.height * _mouthY;
    final mHm = size.height * _mouthH;

    if (state == AvatarState.talking) {
      // Oscilación de apertura
      final openH = (sin(t * 2 * pi * 3) + 1) / 2 * mHm;
      if (openH < 1.0) return;

      // Interior oscuro
      final mouth = Path()
        ..moveTo(cx - mW, mY)
        ..quadraticBezierTo(cx, mY + openH * 0.3, cx + mW, mY)
        ..quadraticBezierTo(cx + mW * 1.05, mY + openH * 0.6, cx + mW, mY + openH)
        ..quadraticBezierTo(cx, mY + openH * 1.2, cx - mW, mY + openH)
        ..quadraticBezierTo(cx - mW * 1.05, mY + openH * 0.6, cx - mW, mY)
        ..close();

      p.color = _mouthOpen;
      canvas.drawPath(mouth, p);

      // Dientes (franja superior)
      if (openH > mHm * 0.3) {
        canvas.save();
        canvas.clipPath(mouth);
        p.color = _teethColor;
        canvas.drawRect(
          Rect.fromLTWH(cx - mW * 0.85, mY, mW * 1.7, openH * 0.45),
          p,
        );
        canvas.restore();
      }

      // Labio superior
      p
        ..color = _lipColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.012
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(
        Path()..moveTo(cx - mW, mY)..quadraticBezierTo(cx, mY + openH * 0.3, cx + mW, mY),
        p,
      );
      p.style = PaintingStyle.fill;
    }
    // En idle/happy/celebrating la boca del PNG ya se ve — no pintamos nada
  }

  @override
  bool shouldRepaint(_FaceOverlayPainter old) =>
      old.t != t || old.state != state;
}

// ── Destellos dorados ─────────────────────────────────────────────────────
class _SparklesPainter extends CustomPainter {
  final double t;
  _SparklesPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final p  = Paint()..color = const Color(0xFFF5C518)..isAntiAlias = true;
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  / 2;

    final spots = [
      Offset(cx - r * 0.75, cy - r * 0.60),
      Offset(cx + r * 0.75, cy - r * 0.60),
      Offset(cx - r * 0.85, cy + r * 0.10),
      Offset(cx + r * 0.85, cy + r * 0.10),
      Offset(cx,            cy - r * 0.90),
    ];

    for (int i = 0; i < spots.length; i++) {
      final sc  = 0.4 + 0.6 * (sin(t * 2 * pi + i * 1.3) + 1) / 2;
      final arm = r * 0.10 * sc;
      canvas.save();
      canvas.translate(spots[i].dx, spots[i].dy);
      canvas.rotate(t * pi + i.toDouble());
      for (int a = 0; a < 4; a++) {
        canvas.save();
        canvas.rotate(a * pi / 2);
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: arm * 0.22, height: arm), p);
        canvas.restore();
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SparklesPainter old) => old.t != t;
}
