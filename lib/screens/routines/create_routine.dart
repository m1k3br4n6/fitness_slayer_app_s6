import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/widgets/exercise_card.dart';
import 'package:fitness_slayer_01/widgets/exercise_search.dart';
import 'package:fitness_slayer_01/providers/workout_provider.dart';
import 'package:provider/provider.dart';

import '../../models/routine.dart';
import '../../services/database_service.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  bool _isSubmitting = false;

  // Controller for new routine's name
  final TextEditingController _routineNameController = TextEditingController();

  @override
  void dispose() {
    _routineNameController.dispose();
    super.dispose();
  }

  Future<void> _navigateAndAddExercise() async {
    final selectedExercise = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExerciseSearchScreen(),
      ),
    );

    if (selectedExercise != null && mounted) {
      setState(() {
        context.read<WorkoutProvider>().addExercise(selectedExercise);
      });
    }
  }

  Future<void> _saveRoutine() async {
    final workoutProvider = context.read<WorkoutProvider>();
    const String currentUserId = 'Bernard'; // TODO: AUTH TEAM

    // Validation needs name and one exercise
    if (_routineNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give your routine a name')),
      );
      return;
    }

    if (workoutProvider.activeExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add some exercises to your routine!')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    });

    // Map Provider data into the Routine model
    final newRoutine = Routine(
      routineName: _routineNameController.text.trim(),
      exercises: workoutProvider.activeExercises.map((activeEx) {
        return RoutineExercise(
          exerciseId: activeEx.exercise.id,
          exerciseName: activeEx.exercise.name,
          targetSets: activeEx.sets.asMap().entries.map((entry) {
            return RoutineSet(
              setNumber: entry.key + 1,
              targetWeight: double.tryParse(entry.value.weight) ?? 0.0,
              targetReps: int.tryParse(entry.value.reps) ?? 0,
            );
          }).toList(),
        );
      }).toList(),
    );

    try {

      await DatabaseService().saveRoutine(currentUserId, newRoutine.toMap());

      if (mounted) {
        workoutProvider.clearWorkout();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routine Saved Successfully!', style: TextStyle(color: Colors.greenAccent))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save routine: $e', style: const TextStyle(color: Colors.redAccent))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutData = context.watch<WorkoutProvider>();

    return Scaffold(
      appBar:  MyAppBar(),
      backgroundColor: Colors.teal[900],
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(
              children: [
                //Text field for the Routine Name
                Container(
                  decoration: BoxDecoration(
                    color: Colors.teal[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _routineNameController,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: 'Routine Name (e.g. Push Day)',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
        
                const SizedBox(height: 16),
        
                ...workoutData.activeExercises.asMap().entries.map((entry) {
                  int index = entry.key;
                  ActiveExercise activeEx = entry.value;
        
                  return ExerciseCard(
                    exerciseIndex: index,
                    exerciseId: activeEx.exercise.id,
                    exerciseName: activeEx.exercise.name,
                    primaryMuscles: activeEx.exercise.primaryMuscles,
                    mechanic: activeEx.exercise.mechanic,
                    force: activeEx.exercise.force,
                    instructions: activeEx.exercise.instructions,
                    onDelete: () {
                      context.read<WorkoutProvider>().removeExercise(index);
                    },
                  );
                }),
        
                const SizedBox(height: 20),
        
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[800],
                    foregroundColor: Colors.tealAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.add_rounded, color: Colors.tealAccent),
                  label: const Text(
                    'Add Exercise',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onPressed: _navigateAndAddExercise,
                ),
        
                const SizedBox(height: 16),
        
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.teal[900],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSubmitting ? null : _saveRoutine,
                    child: Text(
                      _isSubmitting ? 'SAVING...' : 'SAVE ROUTINE',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}