import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/providers/workout_timer.dart';

class WorkoutTimerCard extends StatelessWidget {
  const WorkoutTimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final timerData = context.watch<WorkoutTimerProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.teal[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, color: Colors.white70, size: 28),
            const SizedBox(width: 12),
            Text(
              timerData.formattedTime,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
