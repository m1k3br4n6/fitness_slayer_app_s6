import 'package:fitness_slayer_01/models/completed_workout.dart';

// Calculates XP earned for a completed workout
int calculateWorkoutXp(CompletedWorkout workout) {
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

// Calculates XP and Level
Map<String, int> calculateNewXpAndLevel(int currentXp, int currentLevel, int xpEarned) {
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

// Calculates streak based on last workout date and current workout date
// Rule: Up to 2 skipped days allowed (max 3 days gap)
// - gap <= 0 (same day): keep current streak
// - 1 <= gap <= 3 (next day, 1 or 2 skipped days): streak + 1
// - gap > 3 (3+ skipped days): streak resets to 1
int calculateNewStreak({
  required int currentStreak,
  required DateTime? lastWorkoutDate,
  required DateTime currentWorkoutDate,
}) {
  if (lastWorkoutDate == null) {
    return 1; // First workout
  }

  final lastDate = DateTime(lastWorkoutDate.year, lastWorkoutDate.month, lastWorkoutDate.day);
  final currentDate = DateTime(currentWorkoutDate.year, currentWorkoutDate.month, currentWorkoutDate.day);

  int gapInDays = currentDate.difference(lastDate).inDays;

  if (gapInDays <= 0) {
    return currentStreak < 1 ? 1 : currentStreak;
  } else if (gapInDays <= 3) {
    return (currentStreak < 1 ? 0 : currentStreak) + 1;
  } else {
    return 1;
  }
}
