import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class ChatIAScreen extends StatefulWidget {
  final Map<String, String>? datos;
  const ChatIAScreen({super.key, this.datos});

  @override
  State<ChatIAScreen> createState() => _ChatIAScreenState();
}

class _ChatIAScreenState extends State<ChatIAScreen> {
  final List<_Msg> _msgs = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _loading = false;

  String get _materiaNombre => widget.datos?['materiaNombre'] ?? '';
  String get _temaNombre    => widget.datos?['temaNombre']    ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _agregarBienvenida());
  }

  void _agregarBienvenida() {
    final saludo = _materiaNombre.isNotEmpty
        ? 'Hola, estoy aquí para ayudarte con $_materiaNombre'
            '${_temaNombre.isNotEmpty ? ' — $_temaNombre' : ''}. '
            '¿En qué tienes dudas?'
        : 'Hola, soy tu tutora AprendIA. ¿Sobre qué tema tienes dudas hoy?';
    setState(() => _msgs.add(_Msg(text: saludo, isUser: false)));
  }

  Future<void> _enviar(String texto) async {
    final q = texto.trim();
    if (q.isEmpty || _loading) return;
    _ctrl.clear();
    setState(() {
      _msgs.add(_Msg(text: q, isUser: true));
      _loading = true;
    });
    _scrollAbajo();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _msgs.add(_Msg(text: _respuestaMock(q), isUser: false));
      _loading = false;
    });
    _scrollAbajo();
  }

  String _respuestaMock(String pregunta) {
    final p = pregunta.toLowerCase();
    if (p.contains('no entend') || p.contains('explicar')) {
      return 'Claro, te lo explico de otra manera. '
          '${_temaNombre.isNotEmpty ? 'En "$_temaNombre", ' : ''}'
          'la idea principal es entender el concepto paso a paso. '
          '¿Qué parte específica te genera dudas?';
    }
    if (p.contains('ejemp')) {
      return 'Te doy un ejemplo sencillo relacionado con '
          '${_materiaNombre.isNotEmpty ? _materiaNombre : 'este tema'}. '
          'Imagina una situación de tu vida diaria donde apliques lo que aprendiste. '
          '¿Te ayudó ese ejemplo?';
    }
    if (p.contains('difícil') || p.contains('dificil')) {
      return 'Entiendo que puede sentirse complicado al principio. '
          'Vamos despacio, sin prisa. '
          '¿Me puedes decir exactamente qué parte te cuesta más trabajo?';
    }
    return 'Esa es una muy buena pregunta. '
        '${_temaNombre.isNotEmpty ? 'Sobre "$_temaNombre": ' : ''}'
        'El aprendizaje toma tiempo y cada paso que das cuenta. '
        '¿Quieres que profundice en algún punto específico?';
  }

  void _scrollAbajo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _buildAppBar(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: _msgs.length + (_loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (_loading && i == _msgs.length) return const _TypingBubble();
                return _BubbleRow(msg: _msgs[i]);
              },
            ),
          ),
          _buildSugerencias(),
          _buildInput(),
        ],
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
              onTap: () => context.pop(),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AprendIA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (_materiaNombre.isNotEmpty)
                    Text(
                      _materiaNombre,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSugerencias() {
    final chips = _materiaNombre.isNotEmpty
        ? _chipsParaMateria(_materiaNombre)
        : ['No entendí', 'Dame un ejemplo', '¿Por qué es importante?'];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ActionChip(
          label: Text(chips[i], style: const TextStyle(fontSize: 12)),
          onPressed: _loading ? null : () => _enviar(chips[i]),
          backgroundColor: AppColors.primaryFixed.withValues(alpha: 0.4),
          side: const BorderSide(color: Colors.transparent),
          labelStyle: const TextStyle(color: AppColors.primary),
        ),
      ),
    );
  }

  List<String> _chipsParaMateria(String nombre) {
    final n = nombre.toLowerCase();
    if (n.contains('español') || n.contains('lectura')) {
      return ['No entendí el texto', 'Dame un ejemplo', '¿Qué es la gramática?'];
    }
    if (n.contains('mate') || n.contains('álgebra')) {
      return ['No entendí el ejercicio', 'Dame otro ejemplo', '¿Para qué sirve esto?'];
    }
    if (n.contains('ciencia')) {
      return ['¿Qué es esto?', 'Dame un ejemplo', '¿Por qué ocurre?'];
    }
    if (n.contains('historia')) {
      return ['¿Cuándo pasó?', '¿Por qué es importante?', 'Dame un ejemplo'];
    }
    return ['No entendí', 'Dame un ejemplo', '¿Por qué es importante?'];
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Escribe tu pregunta…',
                  hintStyle: const TextStyle(color: AppColors.outline),
                  filled: true,
                  fillColor: AppColors.surfaceContainer,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: _loading ? null : _enviar,
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _loading ? null : () => _enviar(_ctrl.text),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isUser;
  _Msg({required this.text, required this.isUser});
}

class _BubbleRow extends StatelessWidget {
  final _Msg msg;
  const _BubbleRow({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: AppColors.primary, size: 16),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isUser
                    ? AppColors.primary
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 14,
                  color: msg.isUser ? Colors.white : AppColors.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay = i * 0.15;
                  final v = ((_anim.value - delay).clamp(0.0, 1.0));
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Opacity(
                      opacity: v,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
