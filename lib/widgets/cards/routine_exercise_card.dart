import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitness_slayer_01/models/exercises.dart';
import 'package:fitness_slayer_01/screens/workout/exercise_info_screen.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';

class RoutineSetData {
  String weight;
  String reps;

  RoutineSetData({this.weight = '', this.reps = ''});
}

class RoutineExerciseData {
  final Exercise exercise;
  final List<RoutineSetData> sets;

  RoutineExerciseData({
    required this.exercise,
    required this.sets,
  });
}

class RoutineExerciseCard extends StatefulWidget {
  final int exerciseIndex;
  final RoutineExerciseData routineExercise;
  final VoidCallback onDeleteExercise;
  final VoidCallback onAddSet;
  final Function(int setIndex) onDeleteSet;
  final Function(int setIndex, String weight, String reps) onSetChanged;

  const RoutineExerciseCard({
    super.key,
    required this.exerciseIndex,
    required this.routineExercise,
    required this.onDeleteExercise,
    required this.onAddSet,
    required this.onDeleteSet,
    required this.onSetChanged,
  });

  @override
  State<RoutineExerciseCard> createState() => _RoutineExerciseCardState();
}

class _RoutineExerciseCardState extends State<RoutineExerciseCard> {
  bool _isExpanded = true;

  IconData _getMuscleIcon() {
    if (widget.routineExercise.exercise.primaryMuscles.isEmpty) {
      return Icons.fitness_center;
    }

    String muscle = widget.routineExercise.exercise.primaryMuscles.first.toLowerCase();

    if (['chest', 'shoulders', 'triceps'].contains(muscle)) return Icons.accessibility_new;
    if (['lats', 'middle back', 'lower back', 'biceps', 'forearms'].contains(muscle)) return Icons.rowing;
    if (['quadriceps', 'hamstrings', 'calves', 'glutes', 'abductors', 'adductors'].contains(muscle)) return Icons.directions_run;
    if (['abdominals', 'core'].contains(muscle)) return Icons.sports_gymnastics;

    return Icons.fitness_center;
  }

  @override
  Widget build(BuildContext context) {
    const Color cardColor = AppColors.hearthPanel;
    const Color inputColor = AppColors.woodFrame;
    const Color textColor = AppColors.parchmentBeige;

    final exercise = widget.routineExercise.exercise;
    final sets = widget.routineExercise.sets;
    final bool isCardio = exercise.category.toLowerCase() == 'cardio';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.woodFrame, width: 1),
      ),
      child: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // DYNAMIC ICON
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getMuscleIcon(), color: AppColors.gemGold, size: 28),
                ),
                const SizedBox(width: 16),

                // EXERCISE INFO SCREEN ON TAP
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExerciseInfoScreen(
                            exerciseId: exercise.id,
                            mechanic: exercise.mechanic,
                            force: exercise.force,
                            category: exercise.category,
                            equipment: exercise.equipment,
                            instructions: exercise.instructions,
                            exerciseName: exercise.name,
                            primaryMuscles: exercise.primaryMuscles,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      exercise.name,
                      style: const TextStyle(
                        color: AppColors.parchmentWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
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

                // DELETE EXERCISE POPUP
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.brassBorder),
                  color: inputColor,
                  onSelected: (value) {
                    if (value == 'delete') {
                      widget.onDeleteExercise();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Exercise', style: TextStyle(color: AppColors.crimsonRed)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text('SET', style: TextStyle(color: textColor, fontSize: 12))),
                  Expanded(
                    flex: 2,
                    child: Text(
                      isCardio ? 'TARGET KM' : 'TARGET KG',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      isCardio ? 'TARGET TIME' : 'TARGET REPS',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor, fontSize: 12),
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox()),
                ],
              ),
            ),

            // SETS LIST
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sets.length,
              itemBuilder: (context, index) {
                final currentSet = sets[index];

                return RoutineSetInputRow(
                  setIndex: index,
                  weight: currentSet.weight,
                  reps: currentSet.reps,
                  inputColor: inputColor,
                  onDelete: () => widget.onDeleteSet(index),
                  onWeightChanged: (val) {
                    widget.onSetChanged(index, val, currentSet.reps);
                  },
                  onRepsChanged: (val) {
                    widget.onSetChanged(index, currentSet.weight, val);
                  },
                );
              },
            ),

            // ADD SET BUTTON
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: widget.onAddSet,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: inputColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+ ADD SET',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class RoutineSetInputRow extends StatelessWidget {
  final int setIndex;
  final String weight;
  final String reps;
  final Color inputColor;
  final VoidCallback onDelete;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String> onRepsChanged;

  const RoutineSetInputRow({
    super.key,
    required this.setIndex,
    required this.weight,
    required this.reps,
    required this.inputColor,
    required this.onDelete,
    required this.onWeightChanged,
    required this.onRepsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        children: [
          // SET NUMBER
          Expanded(
            flex: 1,
            child: Text(
              '${setIndex + 1}',
              style: const TextStyle(color: AppColors.parchmentWhite, fontWeight: FontWeight.bold),
            ),
          ),

          // WEIGHT / DISTANCE INPUT
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: inputColor,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: TextFormField(
                initialValue: weight,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                style: const TextStyle(
                  color: AppColors.parchmentWhite,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(color: AppColors.brassBorder),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
                onChanged: onWeightChanged,
              ),
            ),
          ),

          // REPS / TIME INPUT
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: inputColor,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: TextFormField(
                initialValue: reps,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(
                  color: AppColors.parchmentWhite,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(color: AppColors.brassBorder),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
                onChanged: onRepsChanged,
              ),
            ),
          ),

          // DELETE SET BUTTON
          Expanded(
            flex: 1,
            child: Center(
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: inputColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.crimsonRed,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
