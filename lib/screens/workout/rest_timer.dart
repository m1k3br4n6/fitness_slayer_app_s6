import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/providers/workout_timer.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import '../../widgets/app_bar.dart';

class RestTimerCard extends StatefulWidget {
  const RestTimerCard({super.key});

  @override
  State<RestTimerCard> createState() => _RestTimerCardState();
}

class _RestTimerCardState extends State<RestTimerCard> {
  // Controller from circular_countdown_timer from pub dev
  final CountDownController _countDownController = CountDownController();

 //TODO change so that the user has dynamic input per exercise
  final int _totalRestDuration = 120;

  @override
  Widget build(BuildContext context) {
    final timerData = context.watch<WorkoutTimerProvider>();

    // Calculate elapsed time to prevent visual jumping during rebuilds
    int initialElapsed = _totalRestDuration - timerData.restSecondsRemaining;
    if (initialElapsed < 0) initialElapsed = 0;

    return Scaffold(
      // TODO Change to actual user name
      appBar: MyAppBar(),
      backgroundColor: Colors.teal[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.teal[800],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularCountDownTimer( //from circular_countdown_timer
                    controller: _countDownController,
                    width: MediaQuery.of(context).size.width / 2.5,
                    height: MediaQuery.of(context).size.width / 2.5,
                    duration: timerData.restSecondsRemaining,
                    initialDuration: 0,
                    fillColor: Colors.blueAccent[100]!,
                    ringColor: Colors.teal[600]!,
                    backgroundColor: Colors.teal[900],
                    strokeWidth: 15.0,
                    strokeCap: StrokeCap.round,
                    isReverse: true,
                    isReverseAnimation: true,
                    //Validation check
                    autoStart: timerData.isRestRunning && !timerData.isRestPaused,
                    textStyle: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                    textFormat: CountdownTextFormat.MM_SS,
                  ),
                  const SizedBox(height: 24),

                  // Layout Control Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Pause / Resume Toggle Button
                      ElevatedButton.icon(
                        onPressed: () {
                          if (timerData.isRestPaused) {
                            context.read<WorkoutTimerProvider>().resumeRest();
                            _countDownController.resume();
                          } else {
                            context.read<WorkoutTimerProvider>().pauseRest();
                            _countDownController.pause();
                          }
                        },
                        icon: Icon(timerData.isRestPaused ? Icons.play_arrow : Icons.pause),
                        label: Text(timerData.isRestPaused ? 'Resume' : 'Pause'),
                      ),

                      // Restart Button
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<WorkoutTimerProvider>().restartRest(_totalRestDuration);
                          _countDownController.restart(duration: _totalRestDuration);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Restart'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
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
