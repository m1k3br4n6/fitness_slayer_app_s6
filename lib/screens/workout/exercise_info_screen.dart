import 'package:flutter/material.dart';
import 'package:muscle_mapper/muscle_mapper.dart';
import 'exercise_demo_screen.dart';

class ExerciseInfoScreen extends StatelessWidget {
  final String exerciseId;
  final String exerciseName;
  final List<String> primaryMuscles;
  final String mechanic;
  final String force;
  final String category;
  final String equipment;
  final List<String> instructions;

  const ExerciseInfoScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.primaryMuscles,
    required this.mechanic,
    required this.force,
    this.category = 'N/A',
    this.equipment = 'N/A',
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

  // Converts raw strings to Title Case with 'N/A' fallback
  String _capitalize(String? text) {
    if (text == null || text.trim().isEmpty) return 'N/A';
    final trimmed = text.trim();
    return trimmed.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final Set<Muscle> activeMuscles = _getActiveMuscles();

    return Scaffold(
      backgroundColor: Colors.teal[900],
      appBar: AppBar(
        title: Text(exerciseName, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[800],
        iconTheme: IconThemeData(color: Colors.teal[200]),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Colors.greenAccent),
            tooltip: 'View Exercise Demo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExerciseDemoScreen(
                    exerciseId: exerciseId,
                    exerciseName: exerciseName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Muscle highlighter with high-contrast crisp body lines and vibrant active muscle highlight
              Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: Colors.teal[950],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: MuscleMapper(
                  view: _getAnatomyView(),
                  assetProvider: const DefaultAnatomyProvider(),
                  activeMuscles: activeMuscles,
                  muscleColors: {
                    for (var muscle in activeMuscles) muscle: Colors.greenAccent,
                  },
                  baseColor: Colors.white60,
                ),
              ),

              const SizedBox(height: 32),

              // Exercise information & instructions container
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
                        const SizedBox(width: 12),
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

                    const SizedBox(height: 12),

                    // Category & Equipment Row
                    Row(
                      children: [
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
                                const Text('Category', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(_capitalize(category), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                                const Text('Equipment', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(_capitalize(equipment), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 12),

                    // Instructions Header with Visual Demo button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Instructions:',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExerciseDemoScreen(
                                  exerciseId: exerciseId,
                                  exerciseName: exerciseName,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.teal[700],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.teal[200]!.withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.help_outline_rounded, color: Colors.greenAccent, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Visual Demo',
                                  style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
                                child: Text(
                                  '$stepNum',
                                  style: TextStyle(color: Colors.teal[200], fontWeight: FontWeight.bold, fontSize: 11),
                                ),
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
            ],
          ),
        ),
      ),
    );
  }
}
