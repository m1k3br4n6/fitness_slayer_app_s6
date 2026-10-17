import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/models/completed_workout.dart';
import 'package:fitness_slayer_01/widgets/cards/completed_exercise_card.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';

class DayWorkoutDetailScreen extends StatelessWidget {
  final DateTime date;
  final List<CompletedWorkout> workouts;

  const DayWorkoutDetailScreen({
    super.key,
    required this.date,
    required this.workouts,
  });

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final String formattedDate = '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';

    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: Colors.teal[900],
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
                  const Icon(Icons.event, color: Colors.tealAccent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (workouts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.teal[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.fitness_center_outlined, color: Colors.white38, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'No workouts logged on this date.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              )
            else
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
                          color: Colors.teal[800],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal[700]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 22),
                            const SizedBox(width: 10),
                            const Text(
                              'Completed Session',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.timer_outlined, color: Colors.tealAccent, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${workout.durationMinutes} min',
                              style: const TextStyle(
                                color: Colors.tealAccent,
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
