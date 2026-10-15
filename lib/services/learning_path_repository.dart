import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/learning_path.dart';

class LearningPathRepository {
  LearningPathRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<LearningPath>> watchPaths() {
    return _firestore
        .collection('learningPaths')
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((document) => LearningPath.fromMap(
                    document.id,
                    document.data(),
                  ))
              .toList(growable: false),
        );
  }

  Future<LearningPath?> findPath({
    required String track,
    required String level,
    required String duration,
  }) async {
    final snapshot = await _firestore
        .collection('learningPaths')
        .where('track', isEqualTo: track)
        .where('level', isEqualTo: level)
        .where('duration', isEqualTo: duration)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final document = snapshot.docs.first;
    return LearningPath.fromMap(document.id, document.data());
  }
}
