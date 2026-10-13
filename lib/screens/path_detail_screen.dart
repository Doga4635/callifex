import 'package:flutter/material.dart';

import '../models/learning_path.dart';
import 'chat_screen.dart';

class PathDetailScreen extends StatelessWidget {
  const PathDetailScreen({required this.path, super.key});

  final LearningPath path;

  @override
  Widget build(BuildContext context) {
    final color = _color(path.color);
    return Scaffold(
      appBar: AppBar(title: const Text('Öğrenme yolu')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF18233F),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  path.track.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  path.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  path.summary,
                  style: const TextStyle(
                    color: Color(0xFFD0D5E1),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(label: path.level),
                    _MetaChip(label: path.duration),
                    _MetaChip(label: '${path.modules.length} modül'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'Adım adım yol haritan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 15),
          ...path.modules.indexed.map(
            (entry) => _ModuleCard(
              number: entry.$1 + 1,
              module: entry.$2,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  body: SafeArea(
                    child: ChatScreen(pathTitle: path.title),
                  ),
                ),
              ),
            ),
            icon: const Icon(Icons.chat_rounded),
            label: const Text('Bu yol hakkında rehbere sor'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: const Color(0xFF335CFF),
            ),
          ),
        ],
      ),
    );
  }

  static Color _color(String value) {
    final hex = value.replaceFirst('#', '');
    final parsed = hex.length == 6 ? int.tryParse('FF$hex', radix: 16) : null;
    return parsed == null ? const Color(0xFF335CFF) : Color(parsed);
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.number,
    required this.module,
    required this.color,
  });

  final int number;
  final LearningModule module;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  module.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            module.description,
            style: const TextStyle(color: Color(0xFF6C6D68), height: 1.4),
          ),
          const SizedBox(height: 12),
          ...module.lessons.map(
            (lesson) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.play_circle_outline_rounded, color: color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(lesson)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4FA),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              'Uygulama projesi: ${module.project}',
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF34466F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
