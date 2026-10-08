import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/providers/workout_timer.dart';
import 'package:fitness_slayer_01/screens/Pages/rest_timer.dart';

class MiniRestTimer extends StatelessWidget {
  const MiniRestTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final timerData = context.watch<WorkoutTimerProvider>(); //From providers/workout_timer

    return GestureDetector(
      //opens the full timer screen on tap
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RestTimerCard(),
          ),
        );
      },
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: Colors.teal[800],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const Icon(Icons.timer, color: Colors.greenAccent, size: 28),
              const SizedBox(width: 12),

              Text( //From providers/workout_timer
                'Rest: ${timerData.formattedRestTime}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const Spacer(),

              // Play and Pause Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal[900],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    if (timerData.isRestPaused) { //From providers/workout_timer
                      context.read<WorkoutTimerProvider>().resumeRest();
                    } else {
                      context.read<WorkoutTimerProvider>().pauseRest();
                    }
                  },
                  icon: Icon(
                    timerData.isRestPaused ? Icons.play_arrow : Icons.pause,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}