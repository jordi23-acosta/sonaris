import 'dart:convert';
import 'package:http/http.dart' as http;

class IaService {
  static const String _apiKey =
      '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';
  static const String _url = 'https://api.groq.com/openai/v1/chat/completions';

  static const String _sistema = '''
Eres un asistente musical de la app Sonaris, una aplicación para aprender guitarra con detección de acordes por IA.

Sobre la app:
- Detecta acordes de guitarra usando un modelo de machine learning (MLP)
- Acordes disponibles: A (LA Mayor), Am (LA Menor), C (DO Mayor), D (RE Mayor), F (FA Mayor), Bm7 (SI Menor 7ma)
- Tiene niveles: Básico (A, Am, D), Intermedio (C), Difícil (F, Bm7)
- Incluye quiz de teoría, práctica con micrófono y lecciones de teoría musical

Tu rol:
- Responder preguntas sobre guitarra, acordes, teoría musical y la app Sonaris
- Dar consejos de práctica y técnica
- Explicar conceptos musicales de forma simple
- Ayudar con dudas sobre cómo usar la app

Responde siempre en español, de forma concisa y amigable. Máximo 3 párrafos por respuesta.
''';

  Future<String> enviarMensaje(
      List<Map<String, String>> historial, String mensaje) async {
    final messages = [
      {'role': 'system', 'content': _sistema},
      ...historial.map((m) => {'role': m['role']!, 'content': m['text']!}),
      {'role': 'user', 'content': mensaje},
    ];

    final res = await http
        .post(
          Uri.parse(_url),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'llama-3.3-70b-versatile',
            'messages': messages,
            'max_tokens': 512,
            'temperature': 0.7,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200)
      throw Exception('Error ${res.statusCode}: ${res.body}');
    final data = jsonDecode(res.body);
    return data['choices'][0]['message']['content'] as String;
  }
}
