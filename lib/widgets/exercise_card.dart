import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitness_slayer_01/screens/Pages/exercise_info_screen.dart';

class ExerciseCard extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final List<String> primaryMuscles;
  final String mechanic;
  final String force;
  final List<String> instructions;
  final VoidCallback onDelete;

  const ExerciseCard({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.primaryMuscles,
    required this.mechanic,
    required this.force,
    required this.instructions,
    required this.onDelete,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool _isExpanded = true;

  List<Map<String, dynamic>> workoutSets = [
    {'weight': '', 'reps': '', 'isCompleted': false},
    {'weight': '', 'reps': '', 'isCompleted': false},
  ];

  void _addSet() {
    setState(() {
      workoutSets.add({
        'weight': '',
        'reps': '',
        'isCompleted': false,
      });
    });
  }

  void _toggleSetCompletion(int index) {
    setState(() {
      workoutSets[index]['isCompleted'] = !workoutSets[index]['isCompleted'];
    });
  }

  void _deleteSet(int index) {
    setState(() {
      workoutSets.removeAt(index);
    });
  }

  //TODO Front end people make pretty these are just placeholders and not very accurate
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
    final Color cardColor = Colors.teal[800]!;
    final Color inputColor = Colors.teal[900]!;
    final Color completedColor = Colors.green[800]!;
    final Color activeIconColor = Colors.greenAccent;
    final Color textColor = Colors.white70;

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
                  child: Icon(_getMuscleIcon(), color: Colors.greenAccent, size: 28),
                ),
                const SizedBox(width: 16),

                //INFO SCREEN
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExerciseInfoScreen(
                            exerciseId : widget.exerciseId,
                            mechanic : widget.mechanic,
                            force: widget.force,
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

                //HIDE CARD
                IconButton(
                  icon: Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white70
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),

                //DELETE CARD
                //TODO Implement a move up and down the tree
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
                  Expanded(flex: 2, child: Text('KG', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 12))),
                  Expanded(flex: 2, child: Text('REPS', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 12))),
                  const Expanded(flex: 2, child: SizedBox()),
                ],
              ),
            ),

            // SETS LIST
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workoutSets.length,
              itemBuilder: (context, index) {
                return SetInputRow(
                  setIndex: index,
                  setData: workoutSets[index],
                  inputColor: inputColor,
                  completedColor: completedColor,
                  activeIconColor: activeIconColor,
                  onToggleCompletion: () => _toggleSetCompletion(index),
                  onDelete: () => _deleteSet(index),
                );
              },
            ),

            // ADD SET BUTTON
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: _addSet,
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

// -----------------------------------------------------------------------------
// TODO Front end Ui components that can be changed and moved for global styling maybe
// -----------------------------------------------------------------------------
class SetInputRow extends StatelessWidget {
  final int setIndex;
  final Map<String, dynamic> setData;
  final Color inputColor;
  final Color completedColor;
  final Color activeIconColor;
  final VoidCallback onToggleCompletion;
  final VoidCallback onDelete;

  const SetInputRow({
    super.key,
    required this.setIndex,
    required this.setData,
    required this.inputColor,
    required this.completedColor,
    required this.activeIconColor,
    required this.onToggleCompletion,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = setData['isCompleted'];

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

          // WEIGHT INPUT
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
                initialValue: setData['weight'],
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                style: TextStyle(
                    color: isCompleted ? Colors.white54 : Colors.white,
                    fontWeight: FontWeight.w600
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
                onChanged: (value) {
                  setData['weight'] = value;
                },
                enabled: !isCompleted,
              ),
            ),
          ),

          // REPS INPUT
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
                initialValue: setData['reps'],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: TextStyle(
                    color: isCompleted ? Colors.white54 : Colors.white,
                    fontWeight: FontWeight.w600
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
                onChanged: (value) {
                  setData['reps'] = value;
                },
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