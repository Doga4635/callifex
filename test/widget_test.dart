import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:callifex/models/learning_path.dart';
import 'package:callifex/widgets/path_card.dart';

void main() {
  testWidgets('öğrenme yolu kartı bilgileri gösterir ve tıklanabilir', (
    tester,
  ) async {
    var tapped = false;
    const path = LearningPath(
      id: 'frontend-developer',
      title: 'Frontend Geliştirici',
      track: 'Yazılım',
      level: 'Başlangıç',
      duration: '12 hafta',
      summary: 'Web arayüzleri geliştir.',
      color: '#335CFF',
      order: 1,
      modules: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PathCard(path: path, onTap: () => tapped = true),
        ),
      ),
    );

    expect(find.text('YAZILIM'), findsOneWidget);
    expect(find.text('Frontend Geliştirici'), findsOneWidget);
    expect(find.text('Başlangıç  ·  12 hafta  ·  0 modül'), findsOneWidget);

    await tester.tap(find.text('Frontend Geliştirici'));
    expect(tapped, isTrue);
  });
}
