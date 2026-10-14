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
          const SnackBar(content: Text('Routine deleted', style: TextStyle(color: Colors.greenAccent))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e', style: const TextStyle(color: Colors.redAccent))),
        );
      }
    }
  }

  Future<void> _startRoutine(BuildContext context) async {
    try {
      final workoutProvider = context.read<WorkoutProvider>();
      final timerProvider = context.read<WorkoutTimerProvider>();

      // Starts routine and cleans out any old left overs
      workoutProvider.clearWorkout();
      timerProvider.stopAndReset();

     //We only store the ID of the routines with the exercise names and weights/reps
      // So we reroute everything through the json otherwise the exercise details will be empty
      final String jsonString = await rootBundle.loadString('assets/exercises.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      for (var routineEx in routine.exercises) {
        // Match JSON with exercise ID from saved routine
        final matchingJson = jsonData.firstWhere(
              (jsonEx) => jsonEx['id'] == routineEx.exerciseId,
          orElse: () => null,
        );

        if (matchingJson == null) continue;

        // Make a FullExercise object by routing the matching json key through the exercises model
        final fullExercise = Exercise.fromJson(matchingJson);

        workoutProvider.addExercise(fullExercise);
        int newExIndex = workoutProvider.activeExercises.length - 1;

        //Adds all the sets planned for Routine
        while (workoutProvider.activeExercises[newExIndex].sets.length < routineEx.targetSets.length) {
          workoutProvider.addSet(newExIndex);
        }

        //Adds weights and reps planned for routine.
        for (int i = 0; i < routineEx.targetSets.length; i++) {
          final targetSet = routineEx.targetSets[i];
          workoutProvider.updateSetWeight(newExIndex, i, targetSet.targetWeight.toString());
          workoutProvider.updateSetReps(newExIndex, i, targetSet.targetReps.toString());
        }
      }

      if (context.mounted) {
        timerProvider.start();

        // Pop back to home screen so WorkoutPlanning displays the active workout in place
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting routine: $e', style: const TextStyle(color: Colors.redAccent))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: Colors.teal[900],
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
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.tealAccent, size: 28),
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
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
                  tooltip: 'Delete Routine',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.teal[800],
                        title: const Text('Delete Routine?', style: TextStyle(color: Colors.white)),
                        content: const Text('This cannot be undone.', style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteRoutine(context);
                            },
                            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
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
                  color: Colors.teal[800],
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    title: Text(ex.exerciseName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('${ex.targetSets.length} Sets planned', style: const TextStyle(color: Colors.white70)),
                    trailing: const Icon(Icons.fitness_center, color: Colors.greenAccent),
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
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.teal[900],
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
