import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_slayer_01/models/completed_workout.dart';

import '../models/routine.dart';

class DatabaseService {
  Future<void> saveWorkout(String userId, CompletedWorkout workout) async {
    // Navigates to: users / {userId} / workoutsCompleted / {auto-generated-doc-id}
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workoutsCompleted')
        .add(workout.toMap());
  }

  Future<void> saveRoutine(String userId, Map<String, dynamic> routineData) async {
    // Navigates to: users / {userId} / routines / {auto-generated-doc-id}
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('routines')
        .add(routineData);
  }

  Future<void> updateRoutine(String userId, String routineId, Map<String, dynamic> routineData) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('routines')
        .doc(routineId)
        .set(routineData, SetOptions(merge: true));
  }

  // Fetches from: users / {userId} / routines / {auto-generated-doc-id}
  Stream<List<Routine>> getUserRoutines(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('routines')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Routine.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> deleteRoutine(String userId, String routineId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('routines')
        .doc(routineId)
        .delete();
  }
}
