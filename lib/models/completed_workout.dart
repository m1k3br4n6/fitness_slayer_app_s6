class WorkoutSet {
  final int setNumber;
  final double weight;
  final int reps;

  WorkoutSet({required this.setNumber, required this.weight, required this.reps});

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
    };
  }
}

class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;
  final List<WorkoutSet> sets;

  WorkoutExercise({required this.exerciseId, required this.exerciseName, required this.sets});

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      // Maps the list and makes each element its own map
      'sets': sets.map((sets) => sets.toMap()).toList(),
    };
  }
}

class CompletedWorkout {
  final DateTime dateCompleted;
  final int durationMinutes;
  final List<WorkoutExercise> exercises;

  CompletedWorkout({required this.dateCompleted, required this.durationMinutes, required this.exercises});

  Map<String, dynamic> toMap() {
    return {
      'dateCompleted': dateCompleted,
      'durationMinutes': durationMinutes,
      // Maps the list and makes each element its own map
      'exercises': exercises.map((exercises) => exercises.toMap()).toList(),
    };
  }
}