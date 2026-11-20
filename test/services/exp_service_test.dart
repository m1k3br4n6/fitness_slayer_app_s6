import 'package:fitness_slayer_01/models/completed_workout.dart';
import 'package:fitness_slayer_01/services/exp_service.dart';
import 'package:flutter_test/flutter_test.dart';

CompletedWorkout _buildWorkout({
  int exerciseCount = 0,
  int setsPerExercise = 0,
  double weight = 0.0,
  int reps = 0,
  List<WorkoutExercise>? customExercises,
}) {
  if (customExercises != null) {
    return CompletedWorkout(
      dateCompleted: DateTime(2026, 1, 1),
      durationMinutes: 30,
      exercises: customExercises,
    );
  }

  final exercises = List.generate(
    exerciseCount,
    (eIndex) => WorkoutExercise(
      exerciseId: 'ex_$eIndex',
      exerciseName: 'Exercise $eIndex',
      sets: List.generate(
        setsPerExercise,
        (sIndex) => WorkoutSet(
          setNumber: sIndex + 1,
          weight: weight,
          reps: reps,
        ),
      ),
    ),
  );

  return CompletedWorkout(
    dateCompleted: DateTime(2026, 1, 1),
    durationMinutes: 30,
    exercises: exercises,
  );
}

void main() {
  group('ExpService - calculateWorkoutXp', () {
    group('Sets points brackets (0, 1-9 -> 5 pts, 10-19 -> 10 pts, 20+ -> 15 pts)', () {
      test('0 sets yields 0 set points', () {
        final workout = _buildWorkout(exerciseCount: 1, setsPerExercise: 0);
        // 1 exercise = 5 pts, 0 sets = 0 pts, 0 volume = 0 pts -> total 5
        expect(ExpService.calculateWorkoutXp(workout), equals(5));
      });

      test('1 set yields 5 set points (lower threshold)', () {
        final workout = _buildWorkout(exerciseCount: 1, setsPerExercise: 1, weight: 0, reps: 0);
        // 1 exercise = 5 pts, 1 set = 5 pts, 0 volume = 0 pts -> total 10
        expect(ExpService.calculateWorkoutXp(workout), equals(10));
      });

      test('9 sets yields 5 set points (upper threshold)', () {
        final workout = _buildWorkout(exerciseCount: 1, setsPerExercise: 9, weight: 0, reps: 0);
        // 1 exercise = 5 pts, 9 sets = 5 pts, 0 volume = 0 pts -> total 10
        expect(ExpService.calculateWorkoutXp(workout), equals(10));
      });

      test('10 sets yields 10 set points (lower threshold)', () {
        final workout = _buildWorkout(exerciseCount: 1, setsPerExercise: 10, weight: 0, reps: 0);
        // 1 exercise = 5 pts, 10 sets = 10 pts, 0 volume = 0 pts -> total 15
        expect(ExpService.calculateWorkoutXp(workout), equals(15));
      });

      test('19 sets yields 10 set points (upper threshold)', () {
        final workout = _buildWorkout(exerciseCount: 1, setsPerExercise: 19, weight: 0, reps: 0);
        // 1 exercise = 5 pts, 19 sets = 10 pts, 0 volume = 0 pts -> total 15
        expect(ExpService.calculateWorkoutXp(workout), equals(15));
      });

      test('20 sets yields 15 set points (lower threshold)', () {
        final workout = _buildWorkout(exerciseCount: 1, setsPerExercise: 20, weight: 0, reps: 0);
        // 1 exercise = 5 pts, 20 sets = 15 pts, 0 volume = 0 pts -> total 20
        expect(ExpService.calculateWorkoutXp(workout), equals(20));
      });

      test('25 sets yields 15 set points (well above threshold)', () {
        final workout = _buildWorkout(exerciseCount: 1, setsPerExercise: 25, weight: 0, reps: 0);
        // 1 exercise = 5 pts, 25 sets = 15 pts, 0 volume = 0 pts -> total 20
        expect(ExpService.calculateWorkoutXp(workout), equals(20));
      });
    });

    group('Exercises points brackets (0, 1-3 -> 5 pts, 4-6 -> 10 pts, 7+ -> 15 pts)', () {
      test('0 exercises yields 0 exercise points', () {
        final workout = _buildWorkout(exerciseCount: 0);
        expect(ExpService.calculateWorkoutXp(workout), equals(0));
      });

      test('1 exercise yields 5 exercise points (lower threshold)', () {
        final workout = _buildWorkout(exerciseCount: 1, setsPerExercise: 0);
        // 1 exercise = 5 pts
        expect(ExpService.calculateWorkoutXp(workout), equals(5));
      });

      test('3 exercises yields 5 exercise points (upper threshold)', () {
        final workout = _buildWorkout(exerciseCount: 3, setsPerExercise: 0);
        // 3 exercises = 5 pts
        expect(ExpService.calculateWorkoutXp(workout), equals(5));
      });

      test('4 exercises yields 10 exercise points (lower threshold)', () {
        final workout = _buildWorkout(exerciseCount: 4, setsPerExercise: 0);
        // 4 exercises = 10 pts
        expect(ExpService.calculateWorkoutXp(workout), equals(10));
      });

      test('6 exercises yields 10 exercise points (upper threshold)', () {
        final workout = _buildWorkout(exerciseCount: 6, setsPerExercise: 0);
        // 6 exercises = 10 pts
        expect(ExpService.calculateWorkoutXp(workout), equals(10));
      });

      test('7 exercises yields 15 exercise points (lower threshold)', () {
        final workout = _buildWorkout(exerciseCount: 7, setsPerExercise: 0);
        // 7 exercises = 15 pts
        expect(ExpService.calculateWorkoutXp(workout), equals(15));
      });

      test('10 exercises yields 15 exercise points (well above threshold)', () {
        final workout = _buildWorkout(exerciseCount: 10, setsPerExercise: 0);
        // 10 exercises = 15 pts
        expect(ExpService.calculateWorkoutXp(workout), equals(15));
      });
    });

    group('Volume points brackets (0, <3000 -> 5 pts, 3000-6000 -> 10 pts, >6000 -> 15 pts)', () {
      test('0 kg volume yields 0 volume points', () {
        final workout = _buildWorkout(exerciseCount: 1, setsPerExercise: 1, weight: 0, reps: 0);
        // 1 ex (5) + 1 set (5) + 0 vol (0) = 10
        expect(ExpService.calculateWorkoutXp(workout), equals(10));
      });

      test('1 kg volume yields 5 volume points (lower threshold)', () {
        final workout = _buildWorkout(exerciseCount: 1, setsPerExercise: 1, weight: 1, reps: 1);
        // 1 ex (5) + 1 set (5) + 1 kg (5) = 15
        expect(ExpService.calculateWorkoutXp(workout), equals(15));
      });

      test('2999 kg volume yields 5 volume points (upper boundary for < 3000)', () {
        final workout = _buildWorkout(exerciseCount: 1, setsPerExercise: 1, weight: 2999, reps: 1);
        // 1 ex (5) + 1 set (5) + 2999 kg (5) = 15
        expect(ExpService.calculateWorkoutXp(workout), equals(15));
      });

      test('3000 kg volume yields 10 volume points (exact lower threshold for 3000-6000)', () {
        final workout = _buildWorkout(exerciseCount: 1, setsPerExercise: 1, weight: 3000, reps: 1);
        // 1 ex (5) + 1 set (5) + 3000 kg (10) = 20
        expect(ExpService.calculateWorkoutXp(workout), equals(20));
      });

      test('6000 kg volume yields 10 volume points (exact upper threshold for 3000-6000)', () {
        final workout = _buildWorkout(exerciseCount: 1, setsPerExercise: 1, weight: 6000, reps: 1);
        // 1 ex (5) + 1 set (5) + 6000 kg (10) = 20
        expect(ExpService.calculateWorkoutXp(workout), equals(20));
      });

      test('6001 kg volume yields 15 volume points (lower threshold for > 6000)', () {
        final workout = _buildWorkout(exerciseCount: 1, setsPerExercise: 1, weight: 6001, reps: 1);
        // 1 ex (5) + 1 set (5) + 6001 kg (15) = 25
        expect(ExpService.calculateWorkoutXp(workout), equals(25));
      });

      test('10000 kg volume yields 15 volume points', () {
        final workout = _buildWorkout(exerciseCount: 1, setsPerExercise: 1, weight: 10000, reps: 1);
        // 1 ex (5) + 1 set (5) + 10000 kg (15) = 25
        expect(ExpService.calculateWorkoutXp(workout), equals(25));
      });
    });

    group('Ceiling and edge combinations', () {
      test('empty workout with zero exercises returns 0 XP', () {
        final workout = _buildWorkout(exerciseCount: 0);
        expect(ExpService.calculateWorkoutXp(workout), equals(0));
      });

      test('maximum ceiling hits exactly 45 XP with max brackets in all categories', () {
        // 7+ exercises (15 pts), 20+ sets (15 pts), >6000 kg volume (15 pts) -> 45 XP
        final workout = _buildWorkout(
          exerciseCount: 7,
          setsPerExercise: 3, // 7 * 3 = 21 sets (>= 20)
          weight: 50,
          reps: 10, // 21 * 50 * 10 = 10,500 kg (> 6000)
        );
        expect(ExpService.calculateWorkoutXp(workout), equals(45));
      });

      test('workout exceeding ceiling thresholds still caps at 45 XP', () {
        final workout = _buildWorkout(
          exerciseCount: 15,
          setsPerExercise: 4, // 60 sets
          weight: 100,
          reps: 10, // 60 * 1000 = 60,000 kg
        );
        expect(ExpService.calculateWorkoutXp(workout), equals(45));
      });

      test('multi-exercise distribution with varying weights and reps calculates correctly', () {
        final workout = _buildWorkout(
          customExercises: [
            WorkoutExercise(
              exerciseId: 'squat',
              exerciseName: 'Squat',
              sets: [
                WorkoutSet(setNumber: 1, weight: 100, reps: 10), // 1000 kg
                WorkoutSet(setNumber: 2, weight: 100, reps: 10), // 1000 kg
              ],
            ),
            WorkoutExercise(
              exerciseId: 'bench',
              exerciseName: 'Bench Press',
              sets: [
                WorkoutSet(setNumber: 1, weight: 80, reps: 10), // 800 kg
                WorkoutSet(setNumber: 2, weight: 80, reps: 10), // 800 kg
              ],
            ),
          ],
        );
        // 2 exercises: 5 pts (1-3 bracket)
        // 4 total sets: 5 pts (1-9 bracket)
        // 3600 kg volume: 10 pts (3000-6000 bracket)
        // Total = 20 XP
        expect(ExpService.calculateWorkoutXp(workout), equals(20));
      });
    });
  });

  group('ExpService - calculateBossBattleXp', () {
    test('victory awards exactly 30 XP', () {
      expect(ExpService.calculateBossBattleXp(isVictory: true), equals(30));
    });

    test('defeat awards 0 XP', () {
      expect(ExpService.calculateBossBattleXp(isVictory: false), equals(0));
    });
  });

  group('ExpService - calculateNewXpAndLevel', () {
    test('nominal XP gain without level up increments XP and retains level', () {
      final result = ExpService.calculateNewXpAndLevel(20, 1, 30);
      expect(result['xp'], equals(50));
      expect(result['level'], equals(1));
    });

    test('XP gain landing on 99 does not trigger level up', () {
      final result = ExpService.calculateNewXpAndLevel(54, 1, 45);
      expect(result['xp'], equals(99));
      expect(result['level'], equals(1));
    });

    test('XP gain landing exactly on 100 rolls over to 0 XP and increments level by 1', () {
      final result = ExpService.calculateNewXpAndLevel(55, 1, 45);
      expect(result['xp'], equals(0));
      expect(result['level'], equals(2));
    });

    test('XP gain exceeding 100 increments level and keeps remainder XP', () {
      final result = ExpService.calculateNewXpAndLevel(80, 1, 45);
      expect(result['xp'], equals(25));
      expect(result['level'], equals(2));
    });

    test('multi-level rollover rolls over 100 XP per level sequentially', () {
      // 50 + 250 = 300 -> 3 level ups, remainder 0
      final result = ExpService.calculateNewXpAndLevel(50, 1, 250);
      expect(result['xp'], equals(0));
      expect(result['level'], equals(4));
    });

    test('multi-level rollover with remainder retains leftover XP across levels', () {
      // 90 + 225 = 315 -> 3 level ups, remainder 15
      final result = ExpService.calculateNewXpAndLevel(90, 3, 225);
      expect(result['xp'], equals(15));
      expect(result['level'], equals(6));
    });

    test('edge case: initial level below 1 clamps to level 1 baseline', () {
      final resultZero = ExpService.calculateNewXpAndLevel(0, 0, 50);
      expect(resultZero['xp'], equals(50));
      expect(resultZero['level'], equals(1));

      final resultNegative = ExpService.calculateNewXpAndLevel(0, -3, 120);
      expect(resultNegative['xp'], equals(20));
      expect(resultNegative['level'], equals(2));
    });

    test('zero XP earned returns existing level and XP unchanged', () {
      final result = ExpService.calculateNewXpAndLevel(75, 4, 0);
      expect(result['xp'], equals(75));
      expect(result['level'], equals(4));
    });
  });
}
