import 'package:flutter/material.dart';

import '../models/learning_path.dart';

class PathCard extends StatelessWidget {
  const PathCard({required this.path, required this.onTap, super.key});

  final LearningPath path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pathColor = _parseColor(path.color);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: pathColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(_iconFor(path.track), color: pathColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      path.track.toUpperCase(),
                      style: TextStyle(
                        color: pathColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      path.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${path.level}  ·  ${path.duration}  ·  '
                      '${path.modules.length} modül',
                      style: const TextStyle(
                        color: Color(0xFF777871),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            ],
          ),
        ),
      ),
    );
  }

  static Color _parseColor(String value) {
    final normalized = value.replaceFirst('#', '');
    if (normalized.length != 6) return const Color(0xFF335CFF);
    final parsed = int.tryParse('FF$normalized', radix: 16);
    return parsed == null ? const Color(0xFF335CFF) : Color(parsed);
  }

  static IconData _iconFor(String track) {
    switch (track.toLowerCase()) {
      case 'yazılım':
        return Icons.code_rounded;
      case 'ui/ux tasarım':
        return Icons.draw_rounded;
      case 'dijital pazarlama':
        return Icons.campaign_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }
}
