class StreakService {

  // Calculates updated streak count when a user completes a workout session.
  static int calculateNewStreak({
    required int currentStreak,
    required DateTime? lastWorkoutDate,
    required DateTime currentWorkoutDate,
  }) {
    if (lastWorkoutDate == null || currentStreak <= 0) {
      return 1; // First workout or streak loss
    }

    final lastDate = DateTime(lastWorkoutDate.year, lastWorkoutDate.month, lastWorkoutDate.day);
    final currentDate = DateTime(currentWorkoutDate.year, currentWorkoutDate.month, currentWorkoutDate.day);

    int gapInDays = currentDate.difference(lastDate).inDays;

    if (gapInDays <= 0) {
      return currentStreak < 1 ? 1 : currentStreak;
    } else if (gapInDays <= 3) {
      return (currentStreak < 1 ? 0 : currentStreak) + gapInDays;
    } else {
      return 1; // 3+ skipped days
    }
  }

  // Checks if the streak has expired based on current date
  static bool isStreakExpired(DateTime? lastWorkoutDate, DateTime currentDate) {
    if (lastWorkoutDate == null) return false;

    final lastDate = DateTime(lastWorkoutDate.year, lastWorkoutDate.month, lastWorkoutDate.day);
    final today = DateTime(currentDate.year, currentDate.month, currentDate.day);

    int gapInDays = today.difference(lastDate).inDays;
    return gapInDays >= 4;
  }
}
