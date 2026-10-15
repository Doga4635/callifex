import 'dart:async';

import 'package:flutter/material.dart';

import '../models/learning_path.dart';
import '../services/learning_path_repository.dart';
import '../services/path_selection_store.dart';
import 'chat_screen.dart';
import 'home_screen.dart';
import 'paths_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  late final LearningPathRepository _repository;
  late final PathSelectionStore _selectionStore;
  late final Stream<List<LearningPath>> _paths;

  @override
  void initState() {
    super.initState();
    _repository = LearningPathRepository();
    _selectionStore = PathSelectionStore(repository: _repository);
    _paths = _repository.watchPaths();
    unawaited(_selectionStore.load());
  }

  @override
  void dispose() {
    _selectionStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        paths: _paths,
        selectionStore: _selectionStore,
        onBrowsePaths: () => setState(() => _selectedIndex = 1),
      ),
      PathsScreen(paths: _paths, selectionStore: _selectionStore),
      const ChatScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _selectedIndex, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Keşfet',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_rounded),
            label: 'Yollarım',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Rehber',
          ),
        ],
      ),
    );
  }
}
