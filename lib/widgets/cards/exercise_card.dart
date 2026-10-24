import 'package:fitness_slayer_01/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/providers/workout_provider.dart';
import 'package:fitness_slayer_01/screens/workout/exercise_info_screen.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';

import '../../providers/workout_timer.dart';

class ExerciseCard extends StatefulWidget {
  final int exerciseIndex;
  final String exerciseId;
  final String exerciseName;
  final List<String> primaryMuscles;
  final String mechanic;
  final String force;
  final String category;
  final String equipment;
  final List<String> instructions;
  final VoidCallback onDelete;

  const ExerciseCard({
    super.key,
    required this.exerciseIndex,
    required this.exerciseId,
    required this.exerciseName,
    required this.primaryMuscles,
    required this.mechanic,
    required this.force,
    this.category = 'N/A',
    this.equipment = 'N/A',
    required this.instructions,
    required this.onDelete,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool _isExpanded = true;

  IconData _getMuscleIcon() {
    if (widget.primaryMuscles.isEmpty) return Icons.fitness_center;

    String muscle = widget.primaryMuscles.first.toLowerCase();

    if (['chest', 'shoulders', 'triceps'].contains(muscle)) return Icons.accessibility_new;
    if (['lats', 'middle back', 'lower back', 'biceps', 'forearms'].contains(muscle)) return Icons.rowing;
    if (['quadriceps', 'hamstrings', 'calves', 'glutes', 'abductors', 'adductors'].contains(muscle)) return Icons.directions_run;
    if (['abdominals', 'core'].contains(muscle)) return Icons.sports_gymnastics;

    return Icons.fitness_center;
  }

  @override
  Widget build(BuildContext context) {
    const Color cardColor = AppColors.forgeSlate;
    const Color inputColor = AppColors.hearthStone;
    const Color completedColor = AppColors.crimsonWine;
    const Color activeIconColor = AppColors.emberOrange;
    const Color textColor = AppColors.parchmentBeige;

    final provider = context.watch<WorkoutProvider>();

    if (widget.exerciseIndex >= provider.activeExercises.length) {
      return const SizedBox.shrink();
    }

    final activeSets = provider.activeExercises[widget.exerciseIndex].sets;
    final bool isCardio = widget.category.toLowerCase() == 'cardio';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
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

                // INFO SCREEN
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExerciseInfoScreen(
                            exerciseId: widget.exerciseId,
                            mechanic: widget.mechanic,
                            force: widget.force,
                            category: widget.category,
                            equipment: widget.equipment,
                            instructions: widget.instructions,
                            exerciseName: widget.exerciseName,
                            primaryMuscles: widget.primaryMuscles,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      widget.exerciseName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // HIDE CARD
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

                // DELETE CARD
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white70),
                  color: inputColor,
                  onSelected: (value) {
                    if (value == 'delete') {
                      widget.onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Exercise', style: TextStyle(color: Colors.redAccent)),
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
                      isCardio ? 'KM' : 'KG',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      isCardio ? 'TIME' : 'REPS',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor, fontSize: 12),
                    ),
                  ),
                  const Expanded(flex: 2, child: SizedBox()),
                ],
              ),
            ),

            // SETS LIST
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeSets.length,
              itemBuilder: (context, index) {
                final currentSet = activeSets[index];

                return SetInputRow(
                  setIndex: index,
                  weight: currentSet.weight,
                  reps: currentSet.reps,
                  isCompleted: currentSet.isCompleted,
                  inputColor: inputColor,
                  completedColor: completedColor,
                  activeIconColor: activeIconColor,
                  onToggleCompletion: () {
                    if (!currentSet.isCompleted && (currentSet.weight.isEmpty || currentSet.reps.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isCardio
                                ? 'Please enter distance and time first'
                                : 'Please enter weight and reps first',
                          ),
                          backgroundColor: Colors.redAccent,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    if (!currentSet.isCompleted) {
                      context.read<WorkoutTimerProvider>().startRest(120);
                      SoundService.playCommon("pop", 180);
                    }

                    context.read<WorkoutProvider>().toggleSetCompletion(widget.exerciseIndex, index);
                  },
                  onDelete: () {
                    context.read<WorkoutProvider>().removeSet(widget.exerciseIndex, index);
                  },
                  onWeightChanged: (value) {
                    context.read<WorkoutProvider>().updateSetValues(
                      widget.exerciseIndex,
                      index,
                      value,
                      currentSet.reps,
                    );
                  },
                  onRepsChanged: (value) {
                    context.read<WorkoutProvider>().updateSetValues(
                      widget.exerciseIndex,
                      index,
                      currentSet.weight,
                      value,
                    );
                  },
                );
              },
            ),

            // ADD SET BUTTON
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () => context.read<WorkoutProvider>().addSet(widget.exerciseIndex),
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

class SetInputRow extends StatelessWidget {
  final int setIndex;
  final String weight;
  final String reps;
  final bool isCompleted;

  final Color inputColor;
  final Color completedColor;
  final Color activeIconColor;

  final VoidCallback onToggleCompletion;
  final VoidCallback onDelete;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String> onRepsChanged;

  const SetInputRow({
    super.key,
    required this.setIndex,
    required this.weight,
    required this.reps,
    required this.isCompleted,
    required this.inputColor,
    required this.completedColor,
    required this.activeIconColor,
    required this.onToggleCompletion,
    required this.onDelete,
    required this.onWeightChanged,
    required this.onRepsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isCompleted ? completedColor : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // DYNAMIC SET NUMBER
          Expanded(
            flex: 1,
            child: Text(
              '${setIndex + 1}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),

          // WEIGHT / DISTANCE INPUT
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.transparent : inputColor,
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
                style: TextStyle(
                  color: isCompleted ? Colors.white54 : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
                onChanged: onWeightChanged,
                enabled: !isCompleted,
              ),
            ),
          ),

          // REPS / TIME INPUT
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.transparent : inputColor,
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
                style: TextStyle(
                  color: isCompleted ? Colors.white54 : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
                onChanged: onRepsChanged,
                enabled: !isCompleted,
              ),
            ),
          ),

          // ACTION ICONS (Checkmark & Trash)
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: onToggleCompletion,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isCompleted ? activeIconColor : inputColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.check,
                      color: isCompleted ? Colors.black87 : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: inputColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
