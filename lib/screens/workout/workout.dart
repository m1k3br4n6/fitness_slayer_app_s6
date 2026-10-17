import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/widgets/exercise_card.dart';
import 'package:fitness_slayer_01/widgets/exercise_search.dart';
import 'package:fitness_slayer_01/providers/workout_provider.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/models/completed_workout.dart';
import '../../services/database_service.dart';
import 'package:fitness_slayer_01/services/user_stats.dart';
import 'package:fitness_slayer_01/providers/workout_timer.dart';
import 'package:fitness_slayer_01/widgets/workout_timer_card.dart';
import 'package:fitness_slayer_01/widgets/mini_rest_timer.dart';

class WorkoutView extends StatefulWidget {
  final VoidCallback? onWorkoutFinished;

  const WorkoutView({super.key, this.onWorkoutFinished});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerProvider = context.read<WorkoutTimerProvider>();
      if (!timerProvider.isRunning) {
        timerProvider.start();
      }
    });
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

  Future<void> _cancelWorkout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.teal[800],
        title: const Text('Cancel Workout?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to cancel? Progress for this session will be lost.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NO', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CANCEL WORKOUT', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<WorkoutProvider>().clearWorkout();
      context.read<WorkoutTimerProvider>().stopAndReset();
      widget.onWorkoutFinished?.call();
    }
  }

  Future<void> _finishWorkout() async {
    final workoutProvider = context.read<WorkoutProvider>();
    final timerProvider = context.read<WorkoutTimerProvider>();

    final user = context.read<myUser?>();
    final String currentUserId = user?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to save your workout.')),
      );
      return;
    }

    if (workoutProvider.activeExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add some exercises before finishing!')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final completedWorkout = CompletedWorkout(
      dateCompleted: DateTime.now(),
      durationMinutes: timerProvider.elapsedMinutes,
      exercises: workoutProvider.activeExercises.map((activeEx) {
        return WorkoutExercise(
          exerciseId: activeEx.exercise.id,
          exerciseName: activeEx.exercise.name,
          category: activeEx.exercise.category,
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

    try {
      await DatabaseService().saveWorkout(currentUserId, completedWorkout);

      // Updates user's XP, Level, Streak, and lastWorkoutDate in Firestore
      final UserStatsResult stats = await DatabaseService().updateUserStatsForWorkout(currentUserId, completedWorkout);

      if (mounted) {
        workoutProvider.clearWorkout();
        timerProvider.stopAndReset();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Workout Saved! +${stats.earnedXp} XP Earned!  Day Streak: ${stats.newStreak}',
              style: const TextStyle(color: Colors.greenAccent),
            ),
            duration: const Duration(seconds: 4),
          ),
        );

        widget.onWorkoutFinished?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
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

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  const WorkoutTimerCard(),

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
                      category: activeEx.exercise.category,
                      equipment: activeEx.exercise.equipment,
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

                  const SizedBox(height: 24),

                  // Finish Workout button
                  SizedBox(
                    width: 260,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[800],
                        foregroundColor: Colors.tealAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.tealAccent, size: 24),
                      label: const Text(
                        'Finish Workout',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isSubmitting ? null : _finishWorkout,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Cancel Workout button below Finish
                  SizedBox(
                    width: 260,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[800],
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 24),
                      label: const Text(
                        'Cancel Workout',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _cancelWorkout,
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        if (isRestRemaining) const MiniRestTimer(),
      ],
    );
  }
}

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: Colors.teal[900],
      body: WorkoutView(
        onWorkoutFinished: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
