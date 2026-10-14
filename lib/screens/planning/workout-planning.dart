import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/providers/workout_provider.dart';
import 'package:fitness_slayer_01/providers/workout_timer.dart';
import 'package:fitness_slayer_01/screens/workout/workout.dart';
import 'package:fitness_slayer_01/screens/routines/create_routine.dart';
import '../routines/select_routine.dart';

class WorkoutPlanning extends StatefulWidget {
  const WorkoutPlanning({super.key});

  @override
  State<WorkoutPlanning> createState() => _WorkoutPlanningState();
}

class _WorkoutPlanningState extends State<WorkoutPlanning> {
  bool _isWorkoutActive = false;

  void _startWorkout() {
    context.read<WorkoutProvider>().clearWorkout();
    context.read<WorkoutTimerProvider>().stopAndReset();
    context.read<WorkoutTimerProvider>().start();
    setState(() {
      _isWorkoutActive = true;
    });
  }

  void _onWorkoutFinished() {
    setState(() {
      _isWorkoutActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final timerData = context.watch<WorkoutTimerProvider>();
    final workoutData = context.watch<WorkoutProvider>();

    bool hasActiveWorkout = _isWorkoutActive || timerData.isRunning || workoutData.activeExercises.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.teal[900],
      body: hasActiveWorkout
          ? WorkoutView(
              onWorkoutFinished: _onWorkoutFinished,
            )
          : Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 280),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[800],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.add, color: Colors.tealAccent),
                      label: const Text(
                        'New Workout',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: _startWorkout,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[800],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.list_alt, color: Colors.tealAccent),
                      label: const Text(
                        'Select From Routines',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SelectRoutineScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[800],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.playlist_add, color: Colors.tealAccent),
                      label: const Text(
                        'Create New Routines',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateRoutineScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
