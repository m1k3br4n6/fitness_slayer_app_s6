
class Routine {
  final String id;
  final String routineName;
  final List<RoutineExercise> exercises;

  Routine({
    this.id = '',
    required this.routineName,
    required this.exercises,
  });

  Map<String, dynamic> toMap() {
    return {
      'routineName': routineName,
      'exercises': exercises.map((ex) => ex.toMap()).toList(),
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map, String documentId) {
    return Routine(
      id: documentId,
      routineName: map['routineName'] ?? '',
      exercises: (map['exercises'] as List<dynamic>?)
          ?.map((exMap) => RoutineExercise.fromMap(exMap))
          .toList() ??
          [],
    );
  }
}

class RoutineExercise {
  final String exerciseId;
  final String exerciseName;
  final List<RoutineSet> targetSets;

  RoutineExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.targetSets,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'targetSets': targetSets.map((set) => set.toMap()).toList(),
    };
  }

  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      exerciseId: map['exerciseId'] ?? '',
      exerciseName: map['exerciseName'] ?? '',
      targetSets: (map['targetSets'] as List<dynamic>?)
          ?.map((setMap) => RoutineSet.fromMap(setMap))
          .toList() ??
          [],
    );
  }
}

class RoutineSet {
  final int setNumber;
  final double targetWeight;
  final int targetReps;

  RoutineSet({
    required this.setNumber,
    required this.targetWeight,
    required this.targetReps,
  });

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'targetWeight': targetWeight,
      'targetReps': targetReps,
    };
  }

  factory RoutineSet.fromMap(Map<String, dynamic> map) {
    return RoutineSet(
      setNumber: map['setNumber'] ?? 1,
      targetWeight: (map['targetWeight'] ?? 0.0).toDouble(),
      targetReps: map['targetReps'] ?? 0,
    );
  }
}