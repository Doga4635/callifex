import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
          seedColor: const Color(0xFF335CFF),
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
      home: const _FirebaseGate(),
    );
  }
}

class _FirebaseGate extends StatefulWidget {
  const _FirebaseGate();

  @override
  State<_FirebaseGate> createState() => _FirebaseGateState();
}

class _FirebaseGateState extends State<_FirebaseGate> {
  late final Future<FirebaseApp> _firebase = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _firebase,
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
