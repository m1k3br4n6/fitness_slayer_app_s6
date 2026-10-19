import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/models/routine.dart';
import 'package:fitness_slayer_01/models/exercises.dart';
import 'package:fitness_slayer_01/providers/workout_provider.dart';
import 'package:fitness_slayer_01/providers/workout_timer.dart';
import 'package:fitness_slayer_01/screens/routines/create_routine.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import '../../services/database_service.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'dart:convert';

class RoutineDetailScreen extends StatelessWidget {
  final Routine routine;

  const RoutineDetailScreen({super.key, required this.routine});

  Future<void> _deleteRoutine(BuildContext context) async {
    final user = Provider.of<myUser?>(context, listen: false);
    final String currentUserId = user?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUserId.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to delete a routine.')),
        );
      }
      return;
    }

    try {
      await DatabaseService().deleteRoutine(currentUserId, routine.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routine deleted', style: TextStyle(color: AppColors.parchmentWhite))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e', style: const TextStyle(color: AppColors.crimsonRed))),
        );
      }
    }
  }

  Future<void> _startRoutine(BuildContext context) async {
    try {
      final workoutProvider = context.read<WorkoutProvider>();
      final timerProvider = context.read<WorkoutTimerProvider>();

      workoutProvider.clearWorkout();
      timerProvider.stopAndReset();

      final String jsonString = await rootBundle.loadString('assets/exercises.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      for (var routineEx in routine.exercises) {
        final matchingJson = jsonData.firstWhere(
              (jsonEx) => jsonEx['id'] == routineEx.exerciseId,
          orElse: () => null,
        );

        if (matchingJson == null) continue;

        final fullExercise = Exercise.fromJson(matchingJson);

        workoutProvider.addExercise(fullExercise);
        int newExIndex = workoutProvider.activeExercises.length - 1;

        while (workoutProvider.activeExercises[newExIndex].sets.length < routineEx.targetSets.length) {
          workoutProvider.addSet(newExIndex);
        }

        for (int i = 0; i < routineEx.targetSets.length; i++) {
          final targetSet = routineEx.targetSets[i];
          workoutProvider.updateSetWeight(newExIndex, i, targetSet.targetWeight.toString());
          workoutProvider.updateSetReps(newExIndex, i, targetSet.targetReps.toString());
        }
      }

      if (context.mounted) {
        timerProvider.start();

        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting routine: $e', style: const TextStyle(color: AppColors.crimsonRed))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.slateBackdrop,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    routine.routineName,
                    style: const TextStyle(color: AppColors.parchmentWhite, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.gemGold, size: 28),
                  tooltip: 'Edit Routine',
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateRoutineScreen(initialRoutine: routine),
                      ),
                    );
                    if (result == true && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.crimsonRed, size: 28),
                  tooltip: 'Delete Routine',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.hearthPanel,
                        title: const Text('Delete Routine?', style: TextStyle(color: AppColors.parchmentWhite)),
                        content: const Text('This cannot be undone.', style: TextStyle(color: AppColors.brassBorder)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('CANCEL', style: TextStyle(color: AppColors.brassBorder)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteRoutine(context);
                            },
                            child: const Text('DELETE', style: TextStyle(color: AppColors.crimsonRed)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: routine.exercises.length,
              itemBuilder: (context, index) {
                final ex = routine.exercises[index];
                return Card(
                  color: AppColors.hearthPanel,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.woodFrame, width: 1),
                  ),
                  child: ListTile(
                    title: Text(ex.exerciseName, style: const TextStyle(color: AppColors.parchmentWhite, fontWeight: FontWeight.bold)),
                    subtitle: Text('${ex.targetSets.length} Sets planned', style: const TextStyle(color: AppColors.brassBorder)),
                    trailing: const Icon(Icons.fitness_center, color: AppColors.gemGold),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.flameOrange,
                  foregroundColor: AppColors.parchmentWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.play_arrow, size: 28),
                label: const Text(
                  'START ROUTINE',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                onPressed: () => _startRoutine(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
