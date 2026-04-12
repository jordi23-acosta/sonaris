import 'dart:convert';
import 'package:http/http.dart' as http;

class IaService {
  static const String _apiKey = 'AIzaSyC8LsAGntPJZWBbzcP9pDUdSnCnYvQS9aY';
  static const String _url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey';

  static const String _contexto = '''
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
    final contents = [
      {
        'role': 'user',
        'parts': [
          {'text': _contexto}
        ]
      },
      {
        'role': 'model',
        'parts': [
          {
            'text':
                '¡Hola! Soy el asistente de Sonaris. Estoy aquí para ayudarte con guitarra, acordes y todo lo relacionado con la app. ¿En qué puedo ayudarte?'
          }
        ]
      },
      ...historial.map((m) => {
            'role': m['role']!,
            'parts': [
              {'text': m['text']!}
            ]
          }),
      {
        'role': 'user',
        'parts': [
          {'text': mensaje}
        ]
      },
    ];

    final res = await http
        .post(
          Uri.parse(_url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'contents': contents}),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) throw Exception('Error ${res.statusCode}');
    final data = jsonDecode(res.body);
    return data['candidates'][0]['content']['parts'][0]['text'] as String;
  }
}
