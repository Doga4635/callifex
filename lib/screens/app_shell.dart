import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onBrowsePaths: () => setState(() => _selectedIndex = 1)),
      const PathsScreen(),
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
