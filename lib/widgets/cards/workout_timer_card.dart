import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/providers/workout_timer.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';

class WorkoutTimerCard extends StatelessWidget {
  const WorkoutTimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final timerData = context.watch<WorkoutTimerProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: AppColors.hearthPanel,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, color: AppColors.gemGold, size: 28),
            const SizedBox(width: 12),
            Text(
              timerData.formattedTime,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.parchmentWhite,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
