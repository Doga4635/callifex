import 'package:flutter/material.dart';
import '../models/learning_path.dart';
import '../services/learning_path_repository.dart';
import '../widgets/path_card.dart';
import 'path_detail_screen.dart';

class PathsScreen extends StatelessWidget {
  const PathsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LearningPath>>(
      stream: LearningPathRepository().watchPaths(),
      builder: (context, snapshot) {
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Öğrenme yolları',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'İlgini çeken alanı seç. Her yol, izlenecek içerikleri ve '
                    'uygulayacağın projeleri bir araya getirir.',
                    style: TextStyle(color: Color(0xFF70716C), height: 1.45),
                  ),
                  const SizedBox(height: 24),
                  if (snapshot.hasError)
                    Text(
                      'Yollar yüklenemedi: ${snapshot.error}',
                      style: const TextStyle(color: Color(0xFFB3261E)),
                    )
                  else if (!snapshot.hasData)
                    const Center(child: CircularProgressIndicator())
                  else if (snapshot.data!.isEmpty)
                    const Text(
                      'Firestore’da henüz yol yok. Senaryoları README’deki '
                      'yönergeyle ekleyebilirsin.',
                    )
                  else
                    ...snapshot.data!.map(
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
  }
}
