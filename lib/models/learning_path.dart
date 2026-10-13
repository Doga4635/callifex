class LearningPath {
  const LearningPath({
    required this.id,
    required this.title,
    required this.track,
    required this.level,
    required this.duration,
    required this.summary,
    required this.color,
    required this.order,
    required this.modules,
  });

  final String id;
  final String title;
  final String track;
  final String level;
  final String duration;
  final String summary;
  final String color;
  final int order;
  final List<LearningModule> modules;

  factory LearningPath.fromMap(String id, Map<String, dynamic> map) {
    final rawModules = map['modules'];
    if (rawModules is! List) {
      throw FormatException('Senaryo "$id" için modules alanı liste olmalı.');
    }

    return LearningPath(
      id: id,
      title: _requiredString(map, 'title', id),
      track: _requiredString(map, 'track', id),
      level: _requiredString(map, 'level', id),
      duration: _requiredString(map, 'duration', id),
      summary: _requiredString(map, 'summary', id),
      color: _requiredString(map, 'color', id),
      order: map['order'] is int ? map['order'] as int : 0,
      modules: rawModules
          .map((module) {
            if (module is! Map) {
              throw FormatException('Senaryo "$id" içinde geçersiz modül var.');
            }
            return LearningModule.fromMap(Map<String, dynamic>.from(module));
          })
          .toList(growable: false),
    );
  }

  static String _requiredString(
    Map<String, dynamic> map,
    String field,
    String id,
  ) {
    final value = map[field];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Senaryo "$id" için "$field" alanı gerekli.');
    }
    return value;
  }
}

class LearningModule {
  const LearningModule({
    required this.title,
    required this.description,
    required this.project,
    required this.lessons,
  });

  final String title;
  final String description;
  final String project;
  final List<String> lessons;

  factory LearningModule.fromMap(Map<String, dynamic> map) {
    final lessons = map['lessons'];
    if (lessons is! List || lessons.any((lesson) => lesson is! String)) {
      throw const FormatException('Modül lessons alanı metin listesi olmalı.');
    }
    for (final field in ['title', 'description', 'project']) {
      if (map[field] is! String || (map[field] as String).trim().isEmpty) {
        throw FormatException('Modül "$field" alanı gerekli.');
      }
    }
    return LearningModule(
      title: map['title'] as String,
      description: map['description'] as String,
      project: map['project'] as String,
      lessons: List<String>.unmodifiable(lessons.cast<String>()),
    );
  }
}
