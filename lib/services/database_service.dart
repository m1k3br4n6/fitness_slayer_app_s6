import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_slayer_01/models/completed_workout.dart';
import 'package:fitness_slayer_01/services/user_stats.dart';
import 'package:fitness_slayer_01/services/streak_service.dart';

import '../models/routine.dart';

class DatabaseService {

  Future<void> updateUserData(String userId, String username, int coin, int streak, int xp, int level) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'username': username,
      'coin': coin,
      'streak': streak,
      'xp': xp,
      'level': level,
    }, SetOptions(merge: true));
  }

  Future<void> updateSlayerData(String userId, String slayerName, String item, int hp, int atk) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('slayer').doc('SO1').set({
      'slayer_name': slayerName,
      'item_equipped': item,
      'hp': hp,
      'atk': atk
    }, SetOptions(merge: true));
  }

  Future<void> addToInventory(String userId, String itemId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('inventory').doc(itemId).set({
      'item_id': itemId,
    }, SetOptions(merge: true));
  }

  Future<void> updateBMI(String userId, double latestBMI, int prev_age, double prev_weight, double prev_height) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('BMI').doc('userBMI').set({
      'latestBMI': latestBMI,
      'prev_age': prev_age,
      'prev_weight': prev_weight,
      'prev_height': prev_height
    }, SetOptions(merge: true));
  }

  Future<void> addEquipment(String itemId, String imagePath, int atk_bonus, int hp_bonus, String description, String name, double price) async {
    await FirebaseFirestore.instance.collection('equipment_items').doc(itemId).set({
      'name': name,
      'description': description,
      'image_path': imagePath,
      'price': price,
      'hp_bonus': hp_bonus,
      'atk_bonus': atk_bonus,
    }, SetOptions(merge: true));
  }

  Future<void> deleteEquipment(String itemId) async {
    await FirebaseFirestore.instance.collection('equipment_items').doc(itemId).delete();
  }

  Future<void> saveWorkout(String userId, CompletedWorkout workout) async {
    // Navigates to: users / {userId} / workoutsCompleted / {auto-generated-doc-id}
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workoutsCompleted')
        .add(workout.toMap());
  }

  // Checks on app launch if the user's streak has expired (3+ days skipped) and resets streak to 0 in Firestore if expired
  Future<void> checkAndUpdateStreakOnLaunch(String userId) async {
    if (userId.isEmpty) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final docSnap = await userRef.get();

    if (!docSnap.exists) return;

    final data = docSnap.data() ?? {};
    int currentStreak = (data['streak'] as num?)?.toInt() ?? 0;
    DateTime? lastWorkoutDate;

    final rawLastDate = data['lastWorkoutDate'];
    if (rawLastDate is Timestamp) {
      lastWorkoutDate = rawLastDate.toDate();
    } else if (rawLastDate is DateTime) {
      lastWorkoutDate = rawLastDate;
    }

    if (currentStreak > 0 && StreakService.isStreakExpired(lastWorkoutDate, DateTime.now())) {
      await userRef.set({
        'streak': 0,
      }, SetOptions(merge: true));
    }
  }

  // Updates user's XP, Level, Streak, and lastWorkoutDate in Firestore after completing a workout, returning UserStatsResult
  Future<UserStatsResult> updateUserStatsForWorkout(String userId, CompletedWorkout workout) async {
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
    }

    // Query most recent previous completed workout from workoutsCompleted subcollection
    final previousWorkoutsSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workoutsCompleted')
        .orderBy('dateCompleted', descending: true)
        .get();

    for (var doc in previousWorkoutsSnap.docs) {
      final rawDate = doc.data()['dateCompleted'];
      DateTime? d;
      if (rawDate is Timestamp) {
        d = rawDate.toDate();
      } else if (rawDate is DateTime) {
        d = rawDate;
      }

      // Find the most recent workout that occurred BEFORE the current workout being submitted
      if (d != null && d.isBefore(workout.dateCompleted.subtract(const Duration(milliseconds: 10)))) {
        lastWorkoutDate = d;
        break;
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

    return UserStatsResult(
      earnedXp: xpEarned,
      newStreak: newStreak,
    );
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
