import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/usuario_provider.dart';
import '../../../shared/models/user_profile.dart';
import '../../chat/screens/chat_screen.dart';

class TutorChatScreen extends StatelessWidget {
  const TutorChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nivel = context.read<UsuarioProvider>().nivel;
    final level = switch (nivel) {
      'primaria'    => EducationLevel.primaria,
      'secundaria'  => EducationLevel.secundaria,
      _             => EducationLevel.alfabetizacion,
    };
    return ChatScreen(level: level);
  }
}
