import 'package:fitness_slayer_01/screens/workout/rest_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/widgets/cards/exercise_card.dart';
import 'package:fitness_slayer_01/widgets/exercise_search.dart';
import 'package:fitness_slayer_01/providers/workout_provider.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/models/completed_workout.dart';
import '../../services/database_service.dart';
import 'package:fitness_slayer_01/services/user_stats.dart';
import 'package:fitness_slayer_01/services/notification_service.dart';
import 'package:fitness_slayer_01/providers/workout_timer.dart';
import 'package:fitness_slayer_01/widgets/cards/workout_timer_card.dart';
import 'package:fitness_slayer_01/widgets/timers/mini_rest_timer.dart';


class WorkoutView extends StatefulWidget {
  final VoidCallback? onWorkoutFinished;

  const WorkoutView({super.key, this.onWorkoutFinished});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  bool _isSubmitting = false;
  double? _fabYPosition;

  // Sensitivity for fab change if needed i like it loose
  final double _fabSensitivity = 2.5;

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
      MaterialPageRoute(builder: (context) => const ExerciseSearchScreen()),
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
        backgroundColor: AppColors.forgeSlate,
        title: const Text(
          'Cancel Workout?',
          style: TextStyle(color: AppColors.warmIvory),
        ),
        content: const Text(
          'Are you sure you want to cancel? Progress for this session will be lost.',
          style: TextStyle(color: AppColors.parchmentBeige),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'NO',
              style: TextStyle(color: AppColors.parchmentBeige),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'CANCEL WORKOUT',
              style: TextStyle(
                color: AppColors.crimsonWine,
                fontWeight: FontWeight.bold,
              ),
            ),
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
    final String currentUserId =
        user?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.hearthPanel,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.emberOrange, width: 1.5),
          ),
          content: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.emberOrange,
                size: 22,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please sign in to save your workout.',
                  style: TextStyle(
                    color: AppColors.parchmentWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    if (workoutProvider.activeExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.hearthPanel,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.emberOrange, width: 1.5),
          ),
          content: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.emberOrange,
                size: 22,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Add some exercises before finishing!',
                  style: TextStyle(
                    color: AppColors.parchmentWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
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
      final UserStatsResult stats = await DatabaseService()
          .updateUserStatsForWorkout(currentUserId, completedWorkout);

      // Schedule notification reminder to maintain streak
      await NotificationService().scheduleStreakReminder(hoursDelay: 24);

      if (mounted) {
        workoutProvider.clearWorkout();
        timerProvider.stopAndReset();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.hearthPanel,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.gemGold, width: 1.5),
            ),
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.gemGold,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Workout Saved! +${stats.earnedXp} XP Earned!  Day Streak: ${stats.newStreak}',
                    style: const TextStyle(
                      color: AppColors.parchmentWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
          SnackBar(
            backgroundColor: AppColors.hearthPanel,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.crimsonWine, width: 1.5),
            ),
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.crimsonWine,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to save: $e',
                    style: const TextStyle(
                      color: AppColors.parchmentWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutData = context.watch<WorkoutProvider>();
    final timerData = context.watch<WorkoutTimerProvider>();
    bool isRestRemaining = timerData.restSecondsRemaining > 0;

    return Stack(
      children: [
        // WORKOUT MAIN STUFF
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      const WorkoutTimerCard(),

                      ...workoutData.activeExercises.asMap().entries.map((
                        entry,
                      ) {
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
                            context.read<WorkoutProvider>().removeExercise(
                              index,
                            );
                          },
                        );
                      }),

                      const SizedBox(height: 20),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.forgeSlate,
                          foregroundColor: AppColors.warmIvory,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(
                          Icons.add_rounded,
                          color: AppColors.emberOrange,
                        ),
                        label: const Text(
                          'Add Exercise',
                          style: TextStyle(
                            color: AppColors.warmIvory,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: _navigateAndAddExercise,
                      ),

                      const SizedBox(height: 24),

                      // Finish Workout button
                      SizedBox(
                        width: 260,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emberOrange,
                            foregroundColor: AppColors.warmIvory,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.warmIvory,
                            size: 24,
                          ),
                          label: const Text(
                            'Finish Workout',
                            style: TextStyle(
                              color: AppColors.warmIvory,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                            backgroundColor: AppColors.crimsonWine,
                            foregroundColor: AppColors.warmIvory,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: AppColors.warmIvory,
                            size: 24,
                          ),
                          label: const Text(
                            'Cancel Workout',
                            style: TextStyle(
                              color: AppColors.warmIvory,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
          ],
        ),

        // FAB FOR Rest PAGE
        Builder(
          builder: (context) {
            final screenHeight = MediaQuery.of(context).size.height;
            final defaultTop = screenHeight * 0.4;
            final currentTop = (_fabYPosition ?? defaultTop).clamp(
              70.0,
              screenHeight - 160.0,
            );

            return Positioned(
              left: 8,
              top: currentTop,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _fabYPosition =
                        (currentTop + details.delta.dy * _fabSensitivity).clamp(
                          70.0,
                          screenHeight - 160.0,
                        );
                  });
                },
                child: FloatingActionButton(
                  key: const Key('RestFab'),
                  heroTag: 'RestFab',
                  backgroundColor: isRestRemaining
                      ? AppColors.forgeSlate
                      : AppColors.forgeSlate.withValues(alpha: 0.5),
                  foregroundColor: isRestRemaining
                      ? AppColors.questGold
                      : AppColors.questGold.withValues(alpha: 0.35),
                  elevation: isRestRemaining ? 6 : 0,
                  disabledElevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isRestRemaining
                          ? AppColors.hearthBorder
                          : AppColors.hearthBorder.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  onPressed: isRestRemaining
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RestTimerScreen(),
                            ),
                          );
                        }
                      : null,
                  child: const Icon(Icons.shield_sharp, size: 28),
                ),
              ),
            );
          },
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
      backgroundColor: AppColors.obsidianBlack,
      body: WorkoutView(
        onWorkoutFinished: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
