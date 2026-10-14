import 'dart:convert';

import 'package:callifex/services/guide_chat_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Groq REST isteği geçmişi yollar ve yanıtı döndürür', () async {
    final client = _FakeClient(
      (request) async => _jsonResponse({
        'choices': [
          {
            'message': {'content': '  Önce küçük bir proje seç.  '},
          },
        ],
      }),
    );
    final service = GuideChatService(client: client, apiKey: 'test-key');

    final reply = await service.reply(
      history: [
        (role: 'assistant', text: 'Merhaba'),
        (role: 'user', text: 'Nasıl başlarım?'),
      ],
      pathTitle: 'Frontend Geliştirici',
    );

    expect(reply, 'Önce küçük bir proje seç.');
    expect(client.request!.url.host, 'api.groq.com');
    expect(client.request!.headers['Authorization'], 'Bearer test-key');
    final body = jsonDecode(client.requestBody!) as Map<String, dynamic>;
    expect(body['model'], 'openai/gpt-oss-120b');
    final messages = body['messages'] as List<dynamic>;
    expect(messages.first['role'], 'system');
    expect(messages.first['content'], contains('Frontend Geliştirici'));
    expect(messages.last['content'], 'Nasıl başlarım?');

    service.dispose();
  });

  test('eksik API key açık bir yapılandırma hatası verir', () async {
    final service = GuideChatService(
      client: _FakeClient((_) async => _jsonResponse({})),
      apiKey: '',
    );

    await expectLater(
      service.reply(history: [(role: 'user', text: 'Merhaba')]),
      throwsA(isA<GroqChatException>()),
    );

    service.dispose();
  });

  test('Groq hız sınırı hatasını kullanıcıya uygun şekilde bildirir', () async {
    final service = GuideChatService(
      client: _FakeClient((_) async => http.Response('too many requests', 429)),
      apiKey: 'test-key',
    );

    await expectLater(
      service.reply(history: [(role: 'user', text: 'Merhaba')]),
      throwsA(
        isA<GroqChatException>().having(
          (error) => error.message,
          'message',
          contains('Biraz sonra tekrar deneyin'),
        ),
      ),
    );

    service.dispose();
  });
}

http.Response _jsonResponse(Map<String, Object?> value) =>
    http.Response(jsonEncode(value), 200);

class _FakeClient extends http.BaseClient {
  _FakeClient(this._respond);

  final Future<http.Response> Function(http.BaseRequest request) _respond;
  http.BaseRequest? request;
  String? requestBody;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    this.request = request;
    if (request is http.Request) requestBody = request.body;
    final response = await _respond(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}
