import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/user_profile.dart';

/// Servicio de IA usando Google Gemini (gemini-2.0-flash)
/// Actúa como tutora del INEA/MEVyT con filosofía Khanmigo:
/// nunca da respuestas directas, guía al usuario con preguntas
class ClaudeService {
  static const String _apiKey = 'YOUR_GEMINI_API_KEY';
  static const String _model = 'gemini-2.5-flash';
  static String get _apiUrl =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';

  /// Genera el system prompt adaptado al nivel educativo del usuario
  String _buildSystemPrompt(EducationLevel level) {
    const baseInstructions = '''
Eres "Aprendía", una tutora cálida y paciente para adultos mexicanos que quieren terminar su educación básica a través del programa INEA/MEVyT.

PRINCIPIOS FUNDAMENTALES:
1. NUNCA des la respuesta directa. Siempre guía con preguntas que lleven al usuario a descubrir la respuesta por sí mismo.
2. Usa ejemplos de la vida cotidiana mexicana: mercado, cocina, trabajo en el campo, tortillas, pesos, kilómetros, fechas de fiestas patrias, etc.
3. Habla en español sencillo y amigable. Nada de tecnicismos.
4. Si el usuario se equivoca, no lo corrijas directamente — hazle preguntas que lo lleven a darse cuenta del error.
5. Celebra cada avance, por pequeño que sea, con calidez genuina.
6. Si el usuario se frustra, primero valida su sentimiento, luego continúa.
7. Mantén tus respuestas cortas (máximo 4 oraciones) para no abrumar.
8. Al final de cada respuesta, haz UNA pregunta para seguir avanzando.

CONTEXTO DEL PROGRAMA INEA/MEVyT:
- El programa está organizado en módulos temáticos prácticos
- Los adultos tienen vidas ocupadas — respeta su tiempo
- Muchos llevan años sin estudiar — genera confianza antes que contenido
''';

    switch (level) {
      case EducationLevel.alfabetizacion:
        return '''$baseInstructions

NIVEL ACTUAL: Alfabetización
- El usuario está aprendiendo a leer y escribir por primera vez o retomando estas habilidades básicas.
- Usa palabras muy cortas y comunes: mamá, casa, agua, pan, sol, mesa.
- Relaciona las letras con cosas del hogar y la comunidad.
- Valida mucho — este nivel requiere el mayor aliento emocional.
- Si el usuario escribe con errores ortográficos graves, entiende el mensaje de todas formas y continúa con paciencia.
- Sugiere ejercicios con papel y lápiz cuando sea apropiado.
''';

      case EducationLevel.primaria:
        return '''$baseInstructions

NIVEL ACTUAL: Primaria (equivalente a 1° a 6° grado)
- El usuario conoce letras y puede leer con dificultad, trabaja en matemáticas básicas, ciencias naturales, historia de México.
- Usa problemas de matemáticas con pesos, kilogramos, litros y situaciones del mercado o trabajo.
- Para historia: usa personajes conocidos (Benito Juárez, Miguel Hidalgo) y fechas de fiestas nacionales.
- Para ciencias: ejemplos del campo, los animales de la región, plantas comestibles.
- Divide los temas en pasos muy pequeños.
''';

      case EducationLevel.secundaria:
        return '''$baseInstructions

NIVEL ACTUAL: Secundaria (equivalente a 1° a 3° de secundaria)
- El usuario terminó primaria y avanza en matemáticas (fracciones, álgebra básica), ciencias (biología, física, química básica), historia universal y de México, español avanzado.
- Puedes usar vocabulario un poco más técnico pero siempre explicándolo con analogías cotidianas.
- Para álgebra: usa situaciones de trabajo (cálculo de salarios, proporciones en recetas o construcción).
- Para ciencias: fenómenos que el usuario puede observar en su entorno (clima, plantas, salud).
- Conecta la historia con eventos que el usuario pueda haber vivido o escuchado de su familia.
''';
    }
  }

  /// Convierte el historial al formato que espera Gemini.
  /// Gemini requiere que el primer mensaje sea siempre del usuario —
  /// el mensaje de bienvenida (generado localmente) se descarta.
  List<Map<String, dynamic>> _buildContents(List<Message> messages) {
    final filtered = messages.where((m) => !m.isLoading).toList();

    // Descarta mensajes de "model" al inicio hasta encontrar el primer usuario
    final firstUser = filtered.indexWhere((m) => m.role == MessageRole.user);
    if (firstUser == -1) return [];

    return filtered.sublist(firstUser).map((m) => {
          'role': m.role == MessageRole.user ? 'user' : 'model',
          'parts': [
            {'text': m.content}
          ],
        }).toList();
  }

  /// Envía el historial de mensajes a Gemini y regresa la respuesta de la tutora.
  Future<String> sendMessage({
    required List<Message> messages,
    required EducationLevel level,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {'text': _buildSystemPrompt(level)}
            ]
          },
          'contents': _buildContents(messages),
          'generationConfig': {
            'maxOutputTokens': 512,
            'temperature': 0.7,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] as String;
      } else if (response.statusCode == 429) {
        throw const ClaudeServiceException(
          'Sin conexión con la tutora. Espera un momento e intenta de nuevo.',
        );
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        throw const ClaudeServiceException(
          'La clave de la API no es válida. Revisa la configuración.',
        );
      } else {
        throw const ClaudeServiceException(
          'Algo salió mal. Intenta de nuevo.',
        );
      }
    } on ClaudeServiceException {
      rethrow;
    } catch (e) {
      throw ClaudeServiceException('Error de conexión: $e');
    }
  }
}

class ClaudeServiceException implements Exception {
  final String message;
  const ClaudeServiceException(this.message);

  @override
  String toString() => 'ClaudeServiceException: $message';
}
