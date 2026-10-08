import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/widgets/exercise_card.dart';
import 'package:fitness_slayer_01/widgets/exercise_search.dart';
import 'package:fitness_slayer_01/providers/workout_provider.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/models/completed_workout.dart';
import '../../services/database_service.dart';
import 'package:fitness_slayer_01/providers/workout_timer.dart';
import 'package:fitness_slayer_01/widgets/workout_timer_card.dart';
import 'package:fitness_slayer_01/widgets/mini_rest_timer.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {

  bool _isSubmitting = false; //For disabling finish workout button after submit

  @override
  void initState() {
    super.initState();
    // timer provider init as screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutTimerProvider>().start();
    });
  }

  Future<void> _navigateAndAddExercise() async {
    final selectedExercise = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExerciseSearchScreen(), //widgets/exercise_search
      ),
    );

    // If the user picked an exercise add it
    if (selectedExercise != null && mounted) {
      setState(() {
        context.read<WorkoutProvider>().addExercise(selectedExercise);
      });
    }
  }

  Future<void> _finishWorkout() async {
    final workoutProvider = context.read<WorkoutProvider>();
    final timerProvider = context.read<WorkoutTimerProvider>();

    // TODO: AUTH TEAM - Remove hardcoded ID once login is fully ready please.
    const String currentUserId = 'Bernard';

    if (workoutProvider.activeExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add some exercises before finishing!')),
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

    // NEW: Map Provider data into Database Models
    final completedWorkout = CompletedWorkout(
      dateCompleted: DateTime.now(),
      durationMinutes: timerProvider.elapsedMinutes, // TODO: Add real timer later
      exercises: workoutProvider.activeExercises.map((activeEx) {
        return WorkoutExercise(
          exerciseId: activeEx.exercise.id,
          exerciseName: activeEx.exercise.name,
          sets: activeEx.sets.asMap().entries.map((entry) {
            return WorkoutSet(
              setNumber: entry.key + 1,
              weight: double.tryParse(entry.value.weight) ?? 0.0,
              reps: int.tryParse(entry.value.reps) ?? 0,
            );
          }).toList(),
        );
      }).toList(),
    );

    // Push to Firestore using models/completed_workout
    try {

      await DatabaseService().saveWorkout(currentUserId, completedWorkout);

      if (mounted) {
        workoutProvider.clearWorkout();
        timerProvider.stopAndReset();

        // Todo change this later just temp feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout Saved Successfully!', style: TextStyle(color: Colors.greenAccent))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e', style: const TextStyle(color: Colors.redAccent))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final workoutData = context.watch<WorkoutProvider>();
    final timerData = context.watch<WorkoutTimerProvider>();
    bool isRestRemaining = timerData.restSecondsRemaining > 0;

    return Scaffold(
      // TODO Change to actual user name
      appBar: const MyAppBar(
        title: 'John Doe Lv.21',
      ),
      backgroundColor: Colors.teal[900],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [

              // Stopwatch
              const WorkoutTimerCard(),

              // Spread operator lets line read from right to left and after each entry has been mapped with its
              // own key value pair the ... lets each container be its own widget so that each of the objects gets mapped
              // and displayed properly
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

              // TODO Make it look more nicer, right now just for testing
              ElevatedButton(
                onPressed: _navigateAndAddExercise,
                child: const Text('Add Exercise'),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _finishWorkout,
                child: const Text('FINISH WORKOUT'),
              ),
            ],
          ),
        ),
      ),

      //Breadcrumb for miniRestTimer
      bottomNavigationBar: isRestRemaining
          ? const MiniRestTimer()
          : const SizedBox.shrink(),

    );
  }
}