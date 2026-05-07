import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/models/user_profile.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends ConsumerWidget {
  final EducationLevel level;

  const ChatScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider(level));
    final chatNotifier = ref.read(chatProvider(level).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(AppStrings.chatTitle),
            Text(
              level.displayName,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Mi perfil',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de error — altura fija para no desbordarse
          if (chatState.error != null)
            Material(
              color: AppColors.error,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chatState.error!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                      onPressed: chatNotifier.clearError,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),

          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              reverse: false,
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: chatState.messages[index]);
              },
            ),
          ),

          // Campo de entrada
          ChatInput(
            onSend: chatNotifier.sendMessage,
            isLoading: chatState.isLoading,
          ),
        ],
      ),
    );
  }
}
