import 'dart:convert';

import 'package:http/http.dart' as http;

class GuideChatService {
  GuideChatService({
    http.Client? client,
    String? apiKey,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null,
       _apiKey = apiKey ?? const String.fromEnvironment('GROQ_API_KEY');

  static final _endpoint = Uri.https(
    'api.groq.com',
    '/openai/v1/chat/completions',
  );
  static const _model = 'openai/gpt-oss-120b';

  final http.Client _client;
  final bool _ownsClient;
  final String _apiKey;

  Future<String> reply({
    required List<({String role, String text})> history,
    String? pathTitle,
  }) async {
    if (_apiKey.trim().isEmpty ||
        _apiKey == 'your_groq_api_key_here') {
      throw const GroqChatException(
        'Groq API anahtarı bulunamadı. Proje kökünde .env dosyasını oluşturup '
        'uygulamayı --dart-define-from-file=.env ile çalıştırın.',
      );
    }

    if (history.isEmpty) {
      throw const FormatException('Gönderilecek sohbet mesajı bulunamadı.');
    }

    final recentHistory = history.length > 12
        ? history.sublist(history.length - 12)
        : history;
    final messages = [
      {
        'role': 'system',
        'content': _systemPrompt(pathTitle),
      },
      ...recentHistory.map(
        (message) => {
          'role': message.role,
          'content': message.text,
        },
      ),
    ];

    late final http.Response response;
    try {
      response = await _client
          .post(
            _endpoint,
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': messages,
              'temperature': 0.6,
              'max_completion_tokens': 700,
            }),
          )
          .timeout(const Duration(seconds: 30));
    } on Exception catch (error) {
      throw GroqChatException(
        'Groq servisine bağlanılamadı. İnternet bağlantınızı kontrol edip '
        'tekrar deneyin.',
        cause: error,
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const GroqChatException(
        'Groq API anahtarı geçersiz veya bu isteğe yetkili değil.',
      );
    }
    if (response.statusCode == 429) {
      throw const GroqChatException(
        'Groq isteği sınırına ulaşıldı. Biraz sonra tekrar deneyin.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GroqChatException(
        'Groq yanıt veremedi (HTTP ${response.statusCode}). Lütfen tekrar '
        'deneyin.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (error) {
      throw GroqChatException(
        'Groq geçersiz yanıt döndürdü.',
        cause: error,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const GroqChatException('Groq geçersiz yanıt döndürdü.');
    }
    final choices = decoded['choices'];
    final message = choices is List && choices.isNotEmpty
        ? choices.first
        : null;
    final responseMessage = message is Map ? message['message'] : null;
    final content = responseMessage is Map
        ? responseMessage['content']
        : null;
    if (content is! String || content.trim().isEmpty) {
      throw const GroqChatException('Groq boş yanıt döndürdü.');
    }
    return content.trim();
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }

  String _systemPrompt(String? pathTitle) {
    final pathContext = pathTitle == null
        ? 'Belirli bir öğrenme yolu seçilmedi.'
        : 'Öğrencinin incelediği öğrenme yolu: $pathTitle.';
    return '''
Sen Callifex uygulamasının Türkçe öğrenme rehberisin. $pathContext
Yazılım, UI/UX tasarımı ve dijital pazarlama alanlarında kariyer geçişi yapan
öğrencilere kısa, uygulanabilir ve cesaretlendirici yanıtlar ver. Önce öğrencinin
hedefini anlamaya çalış; somut bir sonraki adım öner. Callifex'te bulunmayan
özellikleri varmış gibi anlatma ve kişisel öğrenme yollarını değiştirdiğini iddia
etme. Bu demoda öğrenme yolları önceden hazırlanmıştır.
''';
  }
}

class GroqChatException implements Exception {
  const GroqChatException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
