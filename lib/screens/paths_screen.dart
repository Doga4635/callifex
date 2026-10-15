import 'package:flutter/material.dart';

import '../models/learning_path.dart';
import '../services/path_selection_store.dart';
import '../widgets/add_path_sheet.dart';
import '../widgets/path_card.dart';
import 'path_detail_screen.dart';

class PathsScreen extends StatelessWidget {
  const PathsScreen({
    required this.paths,
    required this.selectionStore,
    super.key,
  });

  final Stream<List<LearningPath>> paths;
  final PathSelectionStore selectionStore;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LearningPath>>(
      stream: paths,
      builder: (context, snapshot) {
        final catalog = snapshot.data ?? const <LearningPath>[];
        return AnimatedBuilder(
          animation: selectionStore,
          builder: (context, _) {
            final selectedPaths = catalog
                .where((path) => selectionStore.contains(path.id))
                .toList(growable: false);
            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            Text(
                              'Öğrenme yollarım',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.7,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Hedeflerine uygun yolları ekle, adım adım '
                              'ilerle.',
                              style: TextStyle(
                                color: Color(0xFF70716C),
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (snapshot.hasError)
                              Text(
                                'Yollar yüklenemedi: ${snapshot.error}',
                                style: const TextStyle(
                                  color: Color(0xFFB3261E),
                                ),
                              )
                            else if (!snapshot.hasData ||
                                !selectionStore.isLoaded)
                              const Center(child: CircularProgressIndicator())
                            else if (selectedPaths.isEmpty)
                              const _EmptyPaths()
                            else
                              ...selectedPaths.map(
                                (path) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: PathCard(
                                          path: path,
                                          onTap: () =>
                                              Navigator.of(context).push(
                                                MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      PathDetailScreen(
                                                        path: path,
                                                      ),
                                                ),
                                              ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Yolu listemden kaldır',
                                        onPressed: () =>
                                            _removePath(context, path),
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed:
                            snapshot.hasData &&
                                !snapshot.hasError &&
                                selectionStore.isLoaded
                            ? () => _addPath(context, catalog)
                            : null,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Yol ekle'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _removePath(BuildContext context, LearningPath path) async {
    try {
      await selectionStore.removePath(path.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Öğrenme yolu listenden kaldırıldı.')),
      );
    } on Exception catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yol listeden kaldırılamadı: $error')),
      );
    }
  }

  Future<void> _addPath(
    BuildContext context,
    List<LearningPath> catalog,
  ) async {
    final tracks = _options(catalog.map((path) => path.track));
    final levels = _options(catalog.map((path) => path.level));
    final durations = _options(
      catalog.map((path) => path.duration),
      compare: _compareDurations,
    );

    final request = await showAddPathSheet(
      context,
      tracks: tracks,
      levels: levels,
      durations: durations,
    );
    if (request == null || !context.mounted) return;

    try {
      final result = await selectionStore.addPath(
        track: request.track,
        level: request.level,
        duration: request.duration,
      );
      if (!context.mounted) return;
      final message = switch (result) {
        AddPathResult.added => 'Öğrenme yolu eklendi.',
        AddPathResult.alreadyAdded => 'Bu öğrenme yolu zaten ekli.',
        AddPathResult.notFound => 'Bu seçeneklere göre yol bulunmamaktadır.',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } on Exception catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Yol eklenemedi: $error')));
    }
  }

  static List<String> _options(
    Iterable<String> values, {
    Comparator<String>? compare,
  }) {
    final options = values.toSet().toList();
    options.sort(compare);
    return options;
  }

  static int _compareDurations(String first, String second) {
    final firstWeeks = int.tryParse(first.split(' ').first) ?? 0;
    final secondWeeks = int.tryParse(second.split(' ').first) ?? 0;
    return firstWeeks.compareTo(secondWeeks);
  }
}

class _EmptyPaths extends StatelessWidget {
  const _EmptyPaths();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.route_outlined, size: 34, color: Color(0xFF7B7D86)),
          SizedBox(height: 10),
          Text(
            'Listelenecek yol bulunmamaktadır.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF70716C),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Hedeflerine uygun bir yol eklemek için aşağıdaki butona dokun.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF85867F), height: 1.4),
          ),
        ],
      ),
    );
  }
}
