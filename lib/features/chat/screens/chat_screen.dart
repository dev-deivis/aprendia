import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/tutor_avatar.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/maestra_avatar.dart';
import '../../../shared/models/message.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final EducationLevel level;

  const ChatScreen({super.key, required this.level});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final GlobalKey<MaestraLuzState> _avatarKey = GlobalKey<MaestraLuzState>();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Hablar el primer mensaje al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messages = ref.read(chatProvider(widget.level)).messages;
      if (messages.isNotEmpty && messages.first.role == MessageRole.assistant) {
        _avatarKey.currentState?.hablar(messages.first.content);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider(widget.level));
    final chatNotifier = ref.read(chatProvider(widget.level).notifier);

    // Escuchar nuevos mensajes para que el avatar hable
    ref.listen(chatProvider(widget.level), (previous, next) {
      if (previous != null && next.messages.length > previous.messages.length) {
        final lastMsg = next.messages.last;
        if (!lastMsg.isLoading && lastMsg.role == MessageRole.assistant) {
          _avatarKey.currentState?.hablar(lastMsg.content);
          // Scroll al final
          Future.delayed(const Duration(milliseconds: 100), () {
            if (scrollController.hasClients) {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    });

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _buildAppBar(context),
      ),
      body: Column(
        children: [
          // Avatar de la tutora animada
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: MaestraLuz(key: _avatarKey, size: 140),
            ),
          ),
          // Banner de error — altura fija para no desbordarse
          if (chatState.error != null)
            Material(
              color: AppColors.error,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chatState.error!,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Botón para descartar el error
                    GestureDetector(
                      onTap: chatNotifier.clearError,
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
            ),

          // Lista de burbujas de mensajes
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: chatState.messages[index],
                  level: widget.level,
                );
              },
            ),
          ),

          // Input adaptado al nivel educativo del usuario
          LevelAwareChatInput(
            level: widget.level,
            onSend: chatNotifier.sendMessage,
            isLoading: chatState.isLoading,
          ),

          AppBottomNavBar(
            onReplay: () {},
            onMic: () {},
            onHelp: () {},
          ),
        ],
      ),
    );
  }

  /// AppBar custom con avatar de la tutora y navegación de retorno
  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: AppColors.surface,
        child: Row(
          children: [
            // Botón de regreso al onboarding para cambiar nivel
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.onboarding),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Avatar pequeño de la tutora con borde
            const TutorAvatar(size: 36, showBorder: true),
            const SizedBox(width: 10),
            // Nombre de la tutora y nivel actual del usuario
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tu tutora',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    widget.level.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Botón para navegar al perfil del usuario
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.onSurfaceVariant,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
