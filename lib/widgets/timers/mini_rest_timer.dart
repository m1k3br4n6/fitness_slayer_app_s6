import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/providers/workout_timer.dart';
import 'package:fitness_slayer_01/screens/workout/rest_timer.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';

class MiniRestTimer extends StatelessWidget {
  const MiniRestTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final timerData = context.watch<WorkoutTimerProvider>();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0, top: 4.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RestTimerCard(),
              ),
            );
          },
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.hearthPanel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.brassBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: AppColors.gemGold, size: 28),
                  const SizedBox(width: 12),

                  Text(
                    'Rest: ${timerData.formattedRestTime}',
                    style: const TextStyle(
                      color: AppColors.parchmentWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.woodFrame,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (timerData.isRestPaused) {
                          context.read<WorkoutTimerProvider>().resumeRest();
                        } else {
                          context.read<WorkoutTimerProvider>().pauseRest();
                        }
                      },
                      icon: Icon(
                        timerData.isRestPaused ? Icons.play_arrow : Icons.pause,
                        color: AppColors.gemGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
