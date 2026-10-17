import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutSet {
  final int setNumber;
  final double weight;
  final int reps;

  WorkoutSet({
    required this.setNumber,
    required this.weight,
    required this.reps,
  });

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
    };
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      setNumber: (map['setNumber'] as num?)?.toInt() ?? 1,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      reps: (map['reps'] as num?)?.toInt() ?? 0,
    );
  }
}

class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;
  final String category;
  final List<WorkoutSet> sets;

  WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    this.category = 'strength',
    required this.sets,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'category': category,
      'sets': sets.map((s) => s.toMap()).toList(),
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      exerciseId: map['exerciseId'] as String? ?? '',
      exerciseName: map['exerciseName'] as String? ?? '',
      category: map['category'] as String? ?? 'strength',
      sets: (map['sets'] as List<dynamic>?)
              ?.map((s) => WorkoutSet.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CompletedWorkout {
  final String? id;
  final DateTime dateCompleted;
  final int durationMinutes;
  final List<WorkoutExercise> exercises;

  CompletedWorkout({
    this.id,
    required this.dateCompleted,
    required this.durationMinutes,
    required this.exercises,
  });

  Map<String, dynamic> toMap() {
    return {
      'dateCompleted': dateCompleted,
      'durationMinutes': durationMinutes,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory CompletedWorkout.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parsedDate;
    final rawDate = map['dateCompleted'];

    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return CompletedWorkout(
      id: docId,
      dateCompleted: parsedDate,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      exercises: (map['exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
