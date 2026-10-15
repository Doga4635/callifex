import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'learning_path_repository.dart';

enum AddPathResult { added, alreadyAdded, notFound }

class PathSelectionStore extends ChangeNotifier {
  PathSelectionStore({
    LearningPathRepository? repository,
    Future<SharedPreferences> Function()? preferencesLoader,
  }) : _repository = repository,
       _preferencesLoader = preferencesLoader ?? SharedPreferences.getInstance;

  static const _storageKey = 'selectedLearningPathIds';

  LearningPathRepository? _repository;
  final Future<SharedPreferences> Function() _preferencesLoader;
  Set<String> _selectedIds = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  Set<String> get selectedIds => Set.unmodifiable(_selectedIds);

  LearningPathRepository get _pathRepository =>
      _repository ??= LearningPathRepository();

  bool contains(String pathId) => _selectedIds.contains(pathId);

  Future<void> load() async {
    if (_isLoaded) return;
    final preferences = await _preferencesLoader();
    _selectedIds = (preferences.getStringList(_storageKey) ?? <String>[])
        .toSet();
    _isLoaded = true;
    notifyListeners();
  }

  Future<AddPathResult> addPath({
    required String track,
    required String level,
    required String duration,
  }) async {
    if (!_isLoaded) await load();

    final path = await _pathRepository.findPath(
      track: track,
      level: level,
      duration: duration,
    );
    if (path == null) return AddPathResult.notFound;
    if (_selectedIds.contains(path.id)) return AddPathResult.alreadyAdded;

    final nextIds = {..._selectedIds, path.id};
    final preferences = await _preferencesLoader();
    final saved = await preferences.setStringList(
      _storageKey,
      nextIds.toList(growable: false),
    );
    if (!saved) {
      throw StateError('Seçilen öğrenme yolu bu cihaza kaydedilemedi.');
    }

    _selectedIds = nextIds;
    notifyListeners();
    return AddPathResult.added;
  }
}
