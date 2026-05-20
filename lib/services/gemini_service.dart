import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const _url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  static const _systemPrompt =
      'Eres Tito, el asistente de moda inteligente de WearEver, una app colombiana '
      'de moda circular sostenible. Ayudas a los usuarios a encontrar prendas, combinar '
      'outfits y tomar decisiones sostenibles sobre su ropa. Respondes en español '
      'colombiano de manera amigable y concisa.';

  static const _scanPrompt =
      'Analiza esta prenda de ropa. Evalúa su estado y calidad visual. '
      'Responde ÚNICAMENTE en formato JSON con estos campos: '
      'grado (A si está en excelente estado para vender, B si está en buen estado '
      'para donar, C si está muy deteriorada para reciclar), '
      'descripcion (máximo 2 oraciones sobre el estado), '
      'recomendacion (Vender/Donar/Reciclar), '
      'puntaje (número del 0 al 100)';

  Future<String> chat(String message, {String? context}) async {
    try {
      final userText = context != null ? '$context\n\n$message' : message;
      final response = await http.post(
        Uri.parse('$_url?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {'text': _systemPrompt}
            ]
          },
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': userText}
              ]
            }
          ],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 512},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['candidates'][0]['content']['parts'][0]['text'] as String;
      }
      throw Exception('HTTP ${response.statusCode}');
    } catch (_) {
      return 'Lo siento, no puedo responder en este momento. Inténtalo de nuevo.';
    }
  }

  Future<Map<String, dynamic>> scanPrenda(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse('$_url?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  }
                },
                {'text': _scanPrompt}
              ]
            }
          ],
          'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 256},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final text =
            data['candidates'][0]['content']['parts'][0]['text'] as String;
        final match = RegExp(r'\{[\s\S]*\}').firstMatch(text);
        if (match != null) {
          return jsonDecode(match.group(0)!) as Map<String, dynamic>;
        }
      }
      throw Exception('parse error');
    } catch (_) {
      return {
        'grado': 'B',
        'descripcion': 'No se pudo analizar la prenda automáticamente.',
        'recomendacion': 'Donar',
        'puntaje': 50,
      };
    }
  }
}
