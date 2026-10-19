import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/models/completed_workout.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';

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
    const Color cardColor = AppColors.hearthPanel;
    const Color rowBgColor = AppColors.woodFrame;
    const Color textColor = AppColors.parchmentBeige;

    final exercise = widget.workoutExercise;
    final bool isCardio = exercise.category.toLowerCase() == 'cardio';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.woodFrame, width: 1),
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
                  child: Icon(
                    isCardio ? Icons.directions_run : Icons.fitness_center,
                    color: AppColors.gemGold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    exercise.exerciseName,
                    style: const TextStyle(
                      color: AppColors.parchmentWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // EXPAND / COLLAPSE
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.brassBorder,
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
                  Expanded(
                    flex: 2,
                    child: Text(
                      isCardio ? 'KM' : 'KG',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      isCardio ? 'TIME' : 'REPS',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
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
                          style: const TextStyle(color: AppColors.gemGold, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          isCardio
                              ? '${set.weight.toStringAsFixed(set.weight.truncateToDouble() == set.weight ? 0 : 1)} km'
                              : '${set.weight.toStringAsFixed(set.weight.truncateToDouble() == set.weight ? 0 : 1)} kg',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.parchmentWhite, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          isCardio ? '${set.reps} min' : '${set.reps} reps',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.parchmentWhite, fontWeight: FontWeight.w600),
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
