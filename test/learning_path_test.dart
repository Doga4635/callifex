import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callifex/models/learning_path.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'demo senaryoları altı yolu ve her kategoriden ikişer örneği içerir',
    () async {
      final json =
          await rootBundle.loadString('assets/data/learning_paths.json');
      final records = jsonDecode(json) as List<dynamic>;
      final paths = records
          .map((record) {
            final map = Map<String, dynamic>.from(record as Map);
            final id = map.remove('id') as String;
            return LearningPath.fromMap(id, map);
          })
          .toList();

      expect(paths, hasLength(6));
      expect(
        paths.where((path) => path.track == 'Yazılım'),
        hasLength(2),
      );
      expect(
        paths.where((path) => path.track == 'UI/UX Tasarım'),
        hasLength(2),
      );
      expect(
        paths.where((path) => path.track == 'Dijital Pazarlama'),
        hasLength(2),
      );
      expect(paths.every((path) => path.modules.isNotEmpty), isTrue);
    },
  );

  test('hatalı öğrenme yolu alanı açıklayıcı hata verir', () {
    expect(
      () => LearningPath.fromMap('missing-title', {
        'track': 'Yazılım',
        'level': 'Başlangıç',
        'duration': '1 hafta',
        'summary': 'Özet',
        'color': '#335CFF',
        'modules': [],
      }),
      throwsFormatException,
    );
  });
}
