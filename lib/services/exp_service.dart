import 'package:fitness_slayer_01/models/completed_workout.dart';

class ExpService {
  // Calculates XP earned from workout based on sets, exercises and volume
  static int calculateWorkoutXp(CompletedWorkout workout) {
    int totalExercises = workout.exercises.length;
    int totalSets = 0;
    double totalVolumeKg = 0.0;

    for (var ex in workout.exercises) {
      totalSets += ex.sets.length;
      for (var set in ex.sets) {
        totalVolumeKg += (set.weight * set.reps);
      }
    }

    // Sets points
    // 5 Points: 1 - 9 Sets | 10 Points: 10 - 19 Sets | 15 Points: 20+ Sets
    int setsPoints = totalSets >= 20 ? 15 : (totalSets >= 10 ? 10 : (totalSets >= 1 ? 5 : 0));

    // Exercises points
    // 5 Points: 1 - 3 Exercises | 10 Points: 4 - 6 Exercises | 15 Points: 7+ Exercises
    int exercisesPoints = totalExercises >= 7 ? 15 : (totalExercises >= 4 ? 10 : (totalExercises >= 1 ? 5 : 0));

    // Volume points
    // 5 Points: < 3,000 kg | 10 Points: 3,000 kg - 6,000 kg | 15 Points: 6,000+ kg
    int volumePoints = totalVolumeKg > 6000 ? 15 : (totalVolumeKg >= 3000 ? 10 : (totalVolumeKg > 0 ? 5 : 0));

    return setsPoints + exercisesPoints + volumePoints;
  }

  // Calculates XP earned from a Boss Battle (+30 XP for victory, 0 for defeat)
  static int calculateBossBattleXp({required bool isVictory}) {
    return isVictory ? 30 : 0;
  }

  // Calculates new XP and Level
  static Map<String, int> calculateNewXpAndLevel(int currentXp, int currentLevel, int xpEarned) {
    int updatedXp = currentXp + xpEarned;
    int updatedLevel = currentLevel < 1 ? 1 : currentLevel;

    while (updatedXp >= 100) {
      updatedXp -= 100;
      updatedLevel += 1;
    }

    return {
      'xp': updatedXp,
      'level': updatedLevel,
    };
  }
}
