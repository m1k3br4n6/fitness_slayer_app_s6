import 'package:flutter/material.dart';
import 'package:muscle_mapper/muscle_mapper.dart';

class ExerciseInfoScreen extends StatelessWidget {
  final String exerciseId;
  final String exerciseName;
  final List<String> primaryMuscles;
  final String mechanic;
  final String force;
  final List<String> instructions;

  const ExerciseInfoScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.primaryMuscles,
    required this.mechanic,
    required this.force,
    required this.instructions,
  });
  Set<Muscle> _getActiveMuscles() {
    Set<Muscle> activeMuscles = {};

    for (String yuhonasMuscle in primaryMuscles) {
      String normalized = yuhonasMuscle.toLowerCase();

      // The package groups sub-muscles together

      //Front of body
      if (normalized == 'chest') activeMuscles.addAll(MuscleGroup.chest.subMuscles);
      if (normalized == 'biceps') activeMuscles.addAll(MuscleGroup.biceps.subMuscles);
      if (normalized == 'shoulders') activeMuscles.addAll(MuscleGroup.deltoids.subMuscles);
      if (normalized == 'abdominals' || normalized == 'core') activeMuscles.addAll(MuscleGroup.abs.subMuscles);
      if (normalized == 'quadriceps') activeMuscles.addAll(MuscleGroup.quads.subMuscles);
      if (normalized == 'calves') activeMuscles.addAll(MuscleGroup.calves.subMuscles);
      if (normalized == 'forearms') activeMuscles.addAll(MuscleGroup.forearms.subMuscles);
      if (normalized == 'traps') activeMuscles.addAll(MuscleGroup.traps.subMuscles);

      //Back of body
      if (normalized == 'triceps') activeMuscles.addAll(MuscleGroup.triceps.subMuscles);
      if (normalized == 'lats' || normalized == 'middle back') activeMuscles.addAll(MuscleGroup.lats.subMuscles);
      if (normalized == 'glutes') activeMuscles.addAll(MuscleGroup.glutes.subMuscles);
      if (normalized == 'lower back') activeMuscles.addAll(MuscleGroup.lowerBack.subMuscles);
      if (normalized == 'hamstrings') activeMuscles.addAll(MuscleGroup.hamstrings.subMuscles);
      if (normalized == 'adductors') activeMuscles.addAll(MuscleGroup.innerThigh.subMuscles);
    }

    return activeMuscles;
  }

  // Automatically determines which side of the model to show
  AnatomyView _getAnatomyView() {
    final backMuscles = [
      'lats',
      'middle back',
      'lower back',
      'glutes',
      'hamstrings',
      'calves',
      'triceps'
    ];
    for (String muscle in primaryMuscles) {
      if (backMuscles.contains(muscle.toLowerCase())) {
        return AnatomyView.back;
      }
    }
    return AnatomyView.front;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[900],
      appBar: AppBar(
        title: Text(exerciseName, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[800],
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //MUSCLE HIGHLIGHTER
              //TODO change the svg so that the highlighted muscle is more visible
              Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                    color: Colors.grey[900],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                ),
                padding: const EdgeInsets.all(20),
                child: MuscleMapper(
                  view: _getAnatomyView(),
                  assetProvider: const DefaultAnatomyProvider(),
                  activeMuscles: _getActiveMuscles(),
                  muscleColors: {
                    for (var muscle in _getActiveMuscles()) muscle: Colors.greenAccent,
                  },
                  baseColor: Colors.white24,
                ),
              ),

              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.teal[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  //TODO Make it look nice and more readable
                  // Reference assets/Exercises for any more tags that need to be added later
                  children: [
                    Text('Targeted Muscle: ${primaryMuscles.join(', ')}',
                      style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                    Text('Mechanic: $mechanic',
                        style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                    Text('Description: ${instructions.join(', ')}',
                        style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // EXERCISE DEMONSTRATION IMAGES
              //TODO Move this somewhere useful to fit in with the UI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/$exerciseId/0.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/$exerciseId/1.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}