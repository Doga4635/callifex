import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'firebase_options.dart';
import 'screens/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CallifexApp());
}

class CallifexApp extends StatelessWidget {
  const CallifexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Callifex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
          surface: const Color(0xFFF7F7F2),
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F7F2),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const _StartupScreen(),
    );
  }
}

class _StartupScreen extends StatefulWidget {
  const _StartupScreen();

  @override
  State<_StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<_StartupScreen> {
  late final Future<FirebaseApp> _firebase = _initializeFirebase();
  Timer? _splashTimer;
  bool _showApp = false;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showApp = true);
    });
  }

  Future<FirebaseApp> _initializeFirebase() async {
    return Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.025),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: _showApp
            ? _FirebaseGate(key: const ValueKey('app'), firebase: _firebase)
            : const _SplashContent(key: ValueKey('splash')),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.white,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.88, end: 1),
            duration: const Duration(milliseconds: 750),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) => Opacity(
              opacity: ((scale - 0.88) / 0.12).clamp(0, 1),
              child: Transform.scale(scale: scale, child: child),
            ),
            child: SvgPicture.asset(
              'assets/data/images/main-logo.svg',
              width: 220,
              semanticsLabel: 'Callifex',
            ),
          ),
        ),
      ),
    );
  }
}

class _FirebaseGate extends StatefulWidget {
  const _FirebaseGate({required this.firebase, super.key});

  final Future<FirebaseApp> firebase;

  @override
  State<_FirebaseGate> createState() => _FirebaseGateState();
}

class _FirebaseGateState extends State<_FirebaseGate> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: widget.firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _SetupError(error: snapshot.error!);
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const AppShell();
      },
    );
  }
}

class _SetupError extends StatelessWidget {
  const _SetupError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 44),
              const SizedBox(height: 16),
              Text(
                'Firebase bağlantısı kurulamadı',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Önce Firebase projesini oluşturup FlutterFire yapılandırmasını '
                'tamamlayın. Kurulum adımları README dosyasında.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '$error',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
