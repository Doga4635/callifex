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
}
