import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/models/exercises.dart';

// track data while the user types
class ActiveSet {
  String weight = '';
  String reps = '';
  bool isCompleted = false;
}

class ActiveExercise {
  final Exercise exercise;
  final List<ActiveSet> sets;

  ActiveExercise({required this.exercise, required this.sets});
}

//  Central storing so all elements can request data
class WorkoutProvider extends ChangeNotifier {
  final List<ActiveExercise> _activeExercises = [];

  List<ActiveExercise> get activeExercises => _activeExercises;

  void addExercise(Exercise exercise) {
    _activeExercises.add(
      ActiveExercise(
        exercise: exercise,
        sets: [ActiveSet(), ActiveSet()],
      ),
    );
    notifyListeners();
  }

  void removeExercise(int index) {
    _activeExercises.removeAt(index);
    notifyListeners();
  }

  void addSet(int exerciseIndex) {
    _activeExercises[exerciseIndex].sets.add(ActiveSet());
    notifyListeners();
  }

  void removeSet(int exerciseIndex, int setIndex) {
    _activeExercises[exerciseIndex].sets.removeAt(setIndex);
    notifyListeners();
  }

  void toggleSetCompletion(int exerciseIndex, int setIndex) {
    _activeExercises[exerciseIndex].sets[setIndex].isCompleted =
    !_activeExercises[exerciseIndex].sets[setIndex].isCompleted;
    notifyListeners();
  }

  void updateSetValues(int exerciseIndex, int setIndex, String weight, String reps) {
    _activeExercises[exerciseIndex].sets[setIndex].weight = weight;
    _activeExercises[exerciseIndex].sets[setIndex].reps = reps;
  }

  void clearWorkout(){
    _activeExercises.clear();
    notifyListeners();
  }
}