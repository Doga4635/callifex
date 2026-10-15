import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/learning_path.dart';
import '../services/path_selection_store.dart';
import '../widgets/path_card.dart';
import 'path_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.paths,
    required this.selectionStore,
    required this.onBrowsePaths,
    super.key,
  });

  final Stream<List<LearningPath>> paths;
  final PathSelectionStore selectionStore;
  final VoidCallback onBrowsePaths;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<List<LearningPath>>(
      stream: paths,
      builder: (context, snapshot) {
        return AnimatedBuilder(
          animation: selectionStore,
          builder: (context, _) {
            final selectedPaths = snapshot.data
                    ?.where((path) => selectionStore.contains(path.id))
                    .toList(growable: false) ??
                const <LearningPath>[];
            return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                  children: [
                    SvgPicture.asset(
                      'assets/data/images/main-logo.svg',
                      width: 160, // İhtiyacınıza göre genişliği ayarlayabilirsiniz
                      height: 40, // İhtiyacınıza göre yüksekliği ayarlayabilirsiniz
                    ),
                    const SizedBox(width: 10),
                    const Spacer(),
                    IconButton.filledTonal(
                      tooltip: 'Bildirimler',
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                  ],
                ),
                  const SizedBox(height: 28),
                  Text(
                    'Kariyerinde yeni bir\nsayfa aç.',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      height: 1.12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Hedefine giden yolu keşfet, öğrenirken üret.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF70716C),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _IntroCard(),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Sana uygun yollar',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: onBrowsePaths,
                        child: const Text('Tümünü gör'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (snapshot.hasError)
                    _InlineError(error: snapshot.error!)
                  else if (!snapshot.hasData)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 26),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (!selectionStore.isLoaded)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 26),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (selectedPaths.isEmpty)
                    const _EmptyPaths()
                  else
                    ...selectedPaths.take(3).map(
                          (path) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PathCard(
                              path: path,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => PathDetailScreen(path: path),
                                ),
                              ),
                            ),
                          ),
                        ),
                ]),
              ),
            ),
          ],
        );
          },
        );
      },
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF18233F),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'ÖĞREN + UYGULA',
                    style: TextStyle(
                      color: Color(0xFFD9E1FF),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                const Text(
                  'Sadece izleme.\nİşin pratiğini yap.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Adım adım öğrenme yolları ve gerçek projeler.',
                  style: TextStyle(color: Color(0xFFBBC4DB), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.rocket_launch_rounded,
            color: Color(0xFF7CE36B),
            size: 52,
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE9E5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Öğrenme yolları yüklenemedi: $error',
        style: const TextStyle(color: Color(0xFF8E3021)),
      ),
    );
  }
}

class _EmptyPaths extends StatelessWidget {
  const _EmptyPaths();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'Listelenecek yol bulunmamaktadır. Sana uygun bir yol eklemek için '
        '“Yollarım” sekmesine göz at.',
      ),
    );
  }
}
