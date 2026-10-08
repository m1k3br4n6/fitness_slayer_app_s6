import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_slayer_01/models/completed_workout.dart';

class DatabaseService {
  Future<void> saveWorkout(String userId, CompletedWorkout workout) async {
    // Navigates to: users / {userId} / workoutsCompleted / {auto-generated-doc-id}
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workoutsCompleted')
        .add(workout.toMap());
  }
}


