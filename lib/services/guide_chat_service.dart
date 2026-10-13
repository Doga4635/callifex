import 'package:firebase_ai/firebase_ai.dart';

class GuideChatService {
  GuideChatService()
    : _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-3.7-flash');

  final GenerativeModel _model;

  Future<String> reply({
    required List<({String role, String text})> history,
    String? pathTitle,
  }) async {
    final conversation = history
        .map(
          (message) =>
              '${message.role == 'user' ? 'Öğrenci' : 'Rehber'}: '
              '${message.text}',
        )
        .join('\n');
    final pathContext = pathTitle == null
        ? 'Belirli bir öğrenme yolu seçilmedi.'
        : 'Öğrencinin incelediği öğrenme yolu: $pathTitle.';
    final prompt =
        '''
Sen Callifex uygulamasının Türkçe öğrenme rehberisin. $pathContext
Yazılım, UI/UX tasarımı ve dijital pazarlama alanlarında kariyer geçişi yapan
öğrencilere kısa, uygulanabilir ve cesaretlendirici yanıtlar ver. Önce öğrencinin
hedefini anlamaya çalış; somut bir sonraki adım öner. Callifex'te bulunmayan
özellikleri varmış gibi anlatma ve kişisel öğrenme yollarını değiştirdiğini iddia
etme. Bu demoda öğrenme yolları önceden hazırlanmıştır.

Konuşma:
$conversation

Rehber olarak sıradaki yanıtını yaz.
''';
    final response = await _model.generateContent([Content.text(prompt)]);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) {
      throw FormatException('AI rehberi boş yanıt döndürdü.');
    }
    return text;
  }
}
