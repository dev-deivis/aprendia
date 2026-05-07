import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/message.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/services/claude_service.dart';
import '../../../core/constants/app_strings.dart';

/// Estado completo del chat
class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier que maneja toda la lógica del chat con la tutora
class ChatNotifier extends StateNotifier<ChatState> {
  final ClaudeService _claudeService;
  final EducationLevel _level;

  ChatNotifier({
    required ClaudeService claudeService,
    required EducationLevel level,
  })  : _claudeService = claudeService,
        _level = level,
        super(const ChatState()) {
    // Agrega el mensaje de bienvenida al iniciar
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    state = state.copyWith(
      messages: [Message.fromAssistant(AppStrings.chatWelcome)],
    );
  }

  /// Envía el mensaje del usuario y espera la respuesta de la tutora
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || state.isLoading) return;

    final userMessage = Message.fromUser(content.trim());
    final updatedMessages = [...state.messages, userMessage];

    // Muestra el mensaje del usuario y el indicador de carga
    state = state.copyWith(
      messages: [...updatedMessages, Message.loading()],
      isLoading: true,
      error: null,
    );

    try {
      final response = await _claudeService.sendMessage(
        // Solo manda mensajes reales (sin el loading)
        messages: updatedMessages,
        level: _level,
      );

      final assistantMessage = Message.fromAssistant(response);

      // Reemplaza el loading con la respuesta real
      state = state.copyWith(
        messages: [...updatedMessages, assistantMessage],
        isLoading: false,
      );
    } on ClaudeServiceException catch (e) {
      state = state.copyWith(
        messages: updatedMessages,
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        messages: updatedMessages,
        isLoading: false,
        error: AppStrings.errorGeneral,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Factory provider — necesita el nivel del usuario como parámetro
final chatProvider = StateNotifierProvider.family<ChatNotifier, ChatState,
    EducationLevel>(
  (ref, level) => ChatNotifier(
    claudeService: ClaudeService(),
    level: level,
  ),
);
