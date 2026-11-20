import 'package:fitness_slayer_01/services/streak_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StreakService - calculateNewStreak', () {
    group('First workout and null/zero streak edge cases', () {
      test('returns 1 when lastWorkoutDate is null (first workout ever)', () {
        final result = StreakService.calculateNewStreak(
          currentStreak: 0,
          lastWorkoutDate: null,
          currentWorkoutDate: DateTime(2026, 3, 10, 14, 30),
        );
        expect(result, equals(1));
      });

      test('returns 1 when lastWorkoutDate is null even if currentStreak was erroneously > 0', () {
        final result = StreakService.calculateNewStreak(
          currentStreak: 5,
          lastWorkoutDate: null,
          currentWorkoutDate: DateTime(2026, 3, 10),
        );
        expect(result, equals(1));
      });

      test('returns 1 when currentStreak is 0 or negative regardless of lastWorkoutDate', () {
        final resultZero = StreakService.calculateNewStreak(
          currentStreak: 0,
          lastWorkoutDate: DateTime(2026, 3, 9),
          currentWorkoutDate: DateTime(2026, 3, 10),
        );
        expect(resultZero, equals(1));

        final resultNegative = StreakService.calculateNewStreak(
          currentStreak: -2,
          lastWorkoutDate: DateTime(2026, 3, 9),
          currentWorkoutDate: DateTime(2026, 3, 10),
        );
        expect(resultNegative, equals(1));
      });
    });

    group('Same-day workout handling (gap <= 0 days)', () {
      test('same calendar day workout preserves existing streak', () {
        final last = DateTime(2026, 4, 15, 8, 0);
        final current = DateTime(2026, 4, 15, 18, 30);

        final result = StreakService.calculateNewStreak(
          currentStreak: 7,
          lastWorkoutDate: last,
          currentWorkoutDate: current,
        );
        expect(result, equals(7));
      });

      test('same calendar day with different times (late night vs early morning) has 0 gap', () {
        final last = DateTime(2026, 4, 15, 23, 59);
        final current = DateTime(2026, 4, 15, 0, 1);

        final result = StreakService.calculateNewStreak(
          currentStreak: 3,
          lastWorkoutDate: last,
          currentWorkoutDate: current,
        );
        expect(result, equals(3));
      });

      test('workout logged in the past (negative gap) returns currentStreak', () {
        final last = DateTime(2026, 4, 16);
        final current = DateTime(2026, 4, 15);

        final result = StreakService.calculateNewStreak(
          currentStreak: 4,
          lastWorkoutDate: last,
          currentWorkoutDate: current,
        );
        expect(result, equals(4));
      });
    });

    group('Active streak increments (gap <= 3 days)', () {
      test('next day workout (gap = 1 day) increments streak by 1', () {
        final last = DateTime(2026, 5, 1, 20, 0);
        final current = DateTime(2026, 5, 2, 7, 0);

        final result = StreakService.calculateNewStreak(
          currentStreak: 5,
          lastWorkoutDate: last,
          currentWorkoutDate: current,
        );
        expect(result, equals(6));
      });

      test('2-day gap increments streak by 2', () {
        final last = DateTime(2026, 5, 1);
        final current = DateTime(2026, 5, 3);

        final result = StreakService.calculateNewStreak(
          currentStreak: 10,
          lastWorkoutDate: last,
          currentWorkoutDate: current,
        );
        expect(result, equals(12));
      });

      test('3-day gap (upper boundary threshold) increments streak by 3', () {
        final last = DateTime(2026, 5, 1);
        final current = DateTime(2026, 5, 4);

        final result = StreakService.calculateNewStreak(
          currentStreak: 10,
          lastWorkoutDate: last,
          currentWorkoutDate: current,
        );
        expect(result, equals(13));
      });

      test('streak increments correctly across month boundary within 3-day gap', () {
        final last = DateTime(2026, 1, 31);
        final current = DateTime(2026, 2, 2); // gap = 2 days

        final result = StreakService.calculateNewStreak(
          currentStreak: 2,
          lastWorkoutDate: last,
          currentWorkoutDate: current,
        );
        expect(result, equals(4));
      });

      test('streak increments correctly across year boundary within 3-day gap', () {
        final last = DateTime(2025, 12, 31);
        final current = DateTime(2026, 1, 1); // gap = 1 day

        final result = StreakService.calculateNewStreak(
          currentStreak: 20,
          lastWorkoutDate: last,
          currentWorkoutDate: current,
        );
        expect(result, equals(21));
      });
    });

    group('Streak loss reset on workout completion (gap >= 4 days)', () {
      test('4-day gap (exact reset boundary) resets streak to 1', () {
        final last = DateTime(2026, 6, 1);
        final current = DateTime(2026, 6, 5); // 4 days later

        final result = StreakService.calculateNewStreak(
          currentStreak: 15,
          lastWorkoutDate: last,
          currentWorkoutDate: current,
        );
        expect(result, equals(1));
      });

      test('5-day gap resets streak to 1', () {
        final last = DateTime(2026, 6, 1);
        final current = DateTime(2026, 6, 6);

        final result = StreakService.calculateNewStreak(
          currentStreak: 30,
          lastWorkoutDate: last,
          currentWorkoutDate: current,
        );
        expect(result, equals(1));
      });

      test('long gap (30 days) resets streak to 1', () {
        final last = DateTime(2026, 6, 1);
        final current = DateTime(2026, 7, 1);

        final result = StreakService.calculateNewStreak(
          currentStreak: 100,
          lastWorkoutDate: last,
          currentWorkoutDate: current,
        );
        expect(result, equals(1));
      });
    });
  });

  group('StreakService - isStreakExpired (app launch expiration check)', () {
    test('returns false when lastWorkoutDate is null (no recorded workout to expire)', () {
      final isExpired = StreakService.isStreakExpired(null, DateTime(2026, 7, 1));
      expect(isExpired, isFalse);
    });

    test('returns false on same day (gap = 0 days)', () {
      final last = DateTime(2026, 7, 10, 8, 0);
      final today = DateTime(2026, 7, 10, 22, 0);
      expect(StreakService.isStreakExpired(last, today), isFalse);
    });

    test('returns false 1 day later (gap = 1 day)', () {
      final last = DateTime(2026, 7, 10);
      final today = DateTime(2026, 7, 11);
      expect(StreakService.isStreakExpired(last, today), isFalse);
    });

    test('returns false 2 days later (gap = 2 days)', () {
      final last = DateTime(2026, 7, 10);
      final today = DateTime(2026, 7, 12);
      expect(StreakService.isStreakExpired(last, today), isFalse);
    });

    test('returns false 3 days later (gap = 3 days, upper active boundary threshold)', () {
      final last = DateTime(2026, 7, 10);
      final today = DateTime(2026, 7, 13);
      expect(StreakService.isStreakExpired(last, today), isFalse);
    });

    test('returns true 4 days later (gap = 4 days, exact expiration boundary threshold)', () {
      final last = DateTime(2026, 7, 10);
      final today = DateTime(2026, 7, 14);
      expect(StreakService.isStreakExpired(last, today), isTrue);
    });

    test('returns true 5+ days later', () {
      final last = DateTime(2026, 7, 10);
      final today = DateTime(2026, 7, 15);
      expect(StreakService.isStreakExpired(last, today), isTrue);
    });

    test('ignores hour/minute differences when checking expiration boundary', () {
      // 2026-07-10 23:59 vs 2026-07-14 00:01 is still calendar gap of 4 days -> expired
      final last = DateTime(2026, 7, 10, 23, 59);
      final today = DateTime(2026, 7, 14, 0, 1);
      expect(StreakService.isStreakExpired(last, today), isTrue);

      // 2026-07-10 00:01 vs 2026-07-13 23:59 is calendar gap of 3 days -> not expired
      final lastActive = DateTime(2026, 7, 10, 0, 1);
      final todayActive = DateTime(2026, 7, 13, 23, 59);
      expect(StreakService.isStreakExpired(lastActive, todayActive), isFalse);
    });
  });
}
