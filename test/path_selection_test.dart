import 'package:callifex/models/learning_path.dart';
import 'package:callifex/screens/home_screen.dart';
import 'package:callifex/screens/paths_screen.dart';
import 'package:callifex/services/path_selection_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('eklenen yol kimliklerini cihaz ayarlarından yükler', () async {
    SharedPreferences.setMockInitialValues({
      'selectedLearningPathIds': ['frontend-developer'],
    });
    final store = PathSelectionStore();

    await store.load();

    expect(store.isLoaded, isTrue);
    expect(store.contains('frontend-developer'), isTrue);
    expect(store.selectedIds, {'frontend-developer'});
    store.dispose();
  });

  testWidgets('cihazda seçilmiş yol ana sayfada listelenir', (tester) async {
    SharedPreferences.setMockInitialValues({
      'selectedLearningPathIds': ['frontend-developer'],
    });
    final store = PathSelectionStore();
    await store.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreen(
            paths: Stream.value([_samplePath]),
            selectionStore: store,
            onBrowsePaths: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Frontend Geliştirici'), findsOneWidget);
    store.dispose();
  });

  testWidgets('boş yol listesi ve yol ekleme formunu gösterir', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = PathSelectionStore();
    await store.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PathsScreen(
            paths: Stream.value([_samplePath]),
            selectionStore: store,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Listelenecek yol bulunmamaktadır.'), findsOneWidget);
    expect(find.text('Frontend Geliştirici'), findsNothing);
    expect(find.text('Yol ekle'), findsOneWidget);

    await tester.tap(find.text('Yol ekle'));
    await tester.pumpAndSettle();

    expect(find.text('Öğrenme yolu ekle'), findsOneWidget);
    expect(find.text('Sektör'), findsOneWidget);
    expect(find.text('Zorluk'), findsOneWidget);
    expect(find.text('Ayırabileceğin toplam süre'), findsOneWidget);
    store.dispose();
  });
}

const _samplePath = LearningPath(
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
