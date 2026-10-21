import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/models/completed_workout.dart';
import 'package:fitness_slayer_01/models/side_quest_entry.dart';
import 'package:fitness_slayer_01/widgets/cards/completed_exercise_card.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';

class DayWorkoutDetailScreen extends StatelessWidget {
  final DateTime date;
  final List<CompletedWorkout> workouts;
  // Defaults to empty so any other screen that opens this one keeps working unchanged
  final List<SideQuestEntry> sideQuests;

  const DayWorkoutDetailScreen({
    super.key,
    required this.date,
    required this.workouts,
    this.sideQuests = const [],
  });

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  Widget _buildSideQuestSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.hearthPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.woodFrame),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.priority_high, color: AppColors.flameOrange, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Side Quests Completed (${sideQuests.length})',
                  style: const TextStyle(
                    color: AppColors.parchmentWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sideQuests.map((quest) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.gemGold, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      quest.text,
                      style: const TextStyle(color: AppColors.parchmentWhite, fontSize: 15),
                    ),
                  ),
                  Text(
                    '+${quest.xp}XP  +${quest.coins}GP',
                    style: const TextStyle(color: AppColors.brassBorder, fontSize: 12),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';

    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.slateBackdrop,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.event, color: AppColors.gemGold, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        color: AppColors.parchmentWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (workouts.isEmpty && sideQuests.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.hearthPanel,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.woodFrame, width: 1),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.fitness_center_outlined, color: AppColors.brassBorder, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'No workouts logged on this date.',
                      style: TextStyle(color: AppColors.brassBorder, fontSize: 16),
                    ),
                  ],
                ),
              ),

            if (sideQuests.isNotEmpty) _buildSideQuestSection(),

            ...workouts.map((workout) {
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Workout Summary Header Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.hearthPanel,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.woodFrame),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.flameOrange, size: 22),
                          const SizedBox(width: 10),
                          const Text(
                            'Completed Session',
                            style: TextStyle(
                              color: AppColors.parchmentWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.timer_outlined, color: AppColors.gemGold, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${workout.durationMinutes} min',
                            style: const TextStyle(
                              color: AppColors.gemGold,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...workout.exercises.map((ex) {
                      return CompletedExerciseCard(
                        workoutExercise: ex,
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}