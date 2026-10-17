import 'package:fitness_slayer_01/models/completed_workout.dart';
import 'package:fitness_slayer_01/services/exp_service.dart';
import 'package:fitness_slayer_01/services/streak_service.dart';

class UserStatsResult {
  final int earnedXp;
  final int newStreak;

  const UserStatsResult({
    required this.earnedXp,
    required this.newStreak,
  });
}

// Calculates XP earned for a completed workout
int calculateWorkoutXp(CompletedWorkout workout) {
  return ExpService.calculateWorkoutXp(workout);
}

// Calculates XP and Level
Map<String, int> calculateNewXpAndLevel(int currentXp, int currentLevel, int xpEarned) {
  return ExpService.calculateNewXpAndLevel(currentXp, currentLevel, xpEarned);
}

// Calculates streak based on last workout date and current workout date
int calculateNewStreak({
  required int currentStreak,
  required DateTime? lastWorkoutDate,
  required DateTime currentWorkoutDate,
}) {
  return StreakService.calculateNewStreak(
    currentStreak: currentStreak,
    lastWorkoutDate: lastWorkoutDate,
    currentWorkoutDate: currentWorkoutDate,
  );
}
