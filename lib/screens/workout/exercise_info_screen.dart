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

      // Front of body
      if (normalized == 'chest') activeMuscles.addAll(MuscleGroup.chest.subMuscles);
      if (normalized == 'biceps') activeMuscles.addAll(MuscleGroup.biceps.subMuscles);
      if (normalized == 'shoulders') activeMuscles.addAll(MuscleGroup.deltoids.subMuscles);
      if (normalized == 'abdominals' || normalized == 'core') activeMuscles.addAll(MuscleGroup.abs.subMuscles);
      if (normalized == 'quadriceps') activeMuscles.addAll(MuscleGroup.quads.subMuscles);
      if (normalized == 'calves') activeMuscles.addAll(MuscleGroup.calves.subMuscles);
      if (normalized == 'forearms') activeMuscles.addAll(MuscleGroup.forearms.subMuscles);
      if (normalized == 'traps') activeMuscles.addAll(MuscleGroup.traps.subMuscles);

      // Back of body
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

  // Converts raw muscle strings, "lower back", to Title Case, "Lower Back"
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    // Calculated ONCE per build phase to eliminate redundant loop evaluations
    final Set<Muscle> activeMuscles = _getActiveMuscles();

    return Scaffold(
      backgroundColor: Colors.teal[900],
      appBar: AppBar(
        title: Text(exerciseName, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[800],
        iconTheme: IconThemeData(color: Colors.teal[200]),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Muscle highlighter
              // Resolved: High contrast base color and desaturated teal highlight color for active muscles
              Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                    color: Colors.grey[900],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.teal[300]!.withValues(alpha: 0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ]
                ),
                padding: const EdgeInsets.all(20),
                child: MuscleMapper(
                  view: _getAnatomyView(),
                  assetProvider: const DefaultAnatomyProvider(),
                  activeMuscles: activeMuscles,
                  muscleColors: {
                    for (var muscle in activeMuscles) muscle: Colors.teal[300]!,
                  },
                  baseColor: Colors.white24,
                ),
              ),

              const SizedBox(height: 32),

              // Exercise information & instructions container
              // Resolved: Formatted dumped text into badges, key-value pills, and a numbered step-by-step list
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.teal[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Target Muscle Badges inline next to "Targeted Muscles:"
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        const Text(
                          'Targeted Muscles:',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        ...primaryMuscles.map((muscle) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.teal[700],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.teal[200]!.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              _capitalize(muscle),
                              style: TextStyle(color: Colors.teal[200], fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Mechanic & Force Row
                    Row(
                      children: [
                        if (mechanic.isNotEmpty)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.teal[900]?.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Mechanic', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                  const SizedBox(height: 2),
                                  Text(_capitalize(mechanic), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        if (mechanic.isNotEmpty && force.isNotEmpty) const SizedBox(width: 12),
                        if (force.isNotEmpty)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.teal[900]?.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Force', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                  const SizedBox(height: 2),
                                  Text(_capitalize(force), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 12),

                    // Numbered Instructions
                    const Text('Instructions:',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    if (instructions.isEmpty)
                      const Text('No instructions provided.', style: TextStyle(color: Colors.white54))
                    else
                      ...instructions.asMap().entries.map((entry) {
                        int stepNum = entry.key + 1;
                        String stepText = entry.value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.teal[700],
                                  shape: BoxShape.circle,
                                ),
                                child: Text('$stepNum',
                                    style: TextStyle(color: Colors.teal[200], fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  stepText,
                                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Exercise demonstration images
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/$exerciseId/0.jpg',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 150,
                            color: Colors.teal[800],
                            child: const Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.teal[800],
                            child: const Icon(Icons.broken_image_outlined, color: Colors.white38, size: 40),
                          );
                        },
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
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 150,
                            color: Colors.teal[800],
                            child: const Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.teal[800],
                            child: const Icon(Icons.broken_image_outlined, color: Colors.white38, size: 40),
                          );
                        },
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