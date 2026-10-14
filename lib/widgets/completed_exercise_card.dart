import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/models/completed_workout.dart';

class CompletedExerciseCard extends StatefulWidget {
  final WorkoutExercise workoutExercise;

  const CompletedExerciseCard({
    super.key,
    required this.workoutExercise,
  });

  @override
  State<CompletedExerciseCard> createState() => _CompletedExerciseCardState();
}

class _CompletedExerciseCardState extends State<CompletedExerciseCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final Color cardColor = Colors.teal[800]!;
    final Color rowBgColor = Colors.teal[900]!;
    final Color textColor = Colors.white70;

    final exercise = widget.workoutExercise;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.greenAccent, size: 22),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    exercise.exerciseName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // EXPAND / COLLAPSE
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),

          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text('SET', style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('KG', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('REPS', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold))),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // READ-ONLY COMPLETED SETS LIST
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercise.sets.length,
              itemBuilder: (context, index) {
                final set = exercise.sets[index];

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: rowBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${set.setNumber}',
                          style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${set.weight.toStringAsFixed(set.weight.truncateToDouble() == set.weight ? 0 : 1)} kg',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${set.reps} reps',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
