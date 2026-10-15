import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_slayer_01/models/completed_workout.dart';
import 'package:fitness_slayer_01/services/user_stats.dart';

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

  // Updates user's XP, Level, Streak, and lastWorkoutDate in Firestore after completing a workout, returning earned XP
  Future<int> updateUserXpForWorkout(String userId, CompletedWorkout workout) async {
    int xpEarned = calculateWorkoutXp(workout);

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final docSnap = await userRef.get();

    int currentXp = 0;
    int currentLevel = 1;
    int currentStreak = 0;
    DateTime? lastWorkoutDate;

    if (docSnap.exists) {
      final data = docSnap.data() ?? {};
      currentXp = (data['xp'] as num?)?.toInt() ?? 0;
      currentLevel = (data['level'] as num?)?.toInt() ?? 1;
      currentStreak = (data['streak'] as num?)?.toInt() ?? 0;

      final rawLastDate = data['lastWorkoutDate'];
      if (rawLastDate is Timestamp) {
        lastWorkoutDate = rawLastDate.toDate();
      } else if (rawLastDate is DateTime) {
        lastWorkoutDate = rawLastDate;
      }
    }

    final xpAndLevel = calculateNewXpAndLevel(currentXp, currentLevel, xpEarned);
    int newStreak = calculateNewStreak(
      currentStreak: currentStreak,
      lastWorkoutDate: lastWorkoutDate,
      currentWorkoutDate: workout.dateCompleted,
    );

    await userRef.set({
      'xp': xpAndLevel['xp'],
      'level': xpAndLevel['level'],
      'streak': newStreak,
      'lastWorkoutDate': workout.dateCompleted,
    }, SetOptions(merge: true));

    return xpEarned;
  }

  Stream<List<CompletedWorkout>> getUserCompletedWorkouts(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workoutsCompleted')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CompletedWorkout.fromMap(doc.data(), doc.id))
            .toList());
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
