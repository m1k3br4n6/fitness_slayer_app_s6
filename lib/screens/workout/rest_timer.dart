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
  final CountDownController _countDownController = CountDownController();

  final int _totalRestDuration = 120;

  @override
  Widget build(BuildContext context) {
    final timerData = context.watch<WorkoutTimerProvider>();

    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: Colors.teal[900],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.teal[800],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Title
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer_outlined, color: Colors.greenAccent, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Rest Timer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Status Indicator Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: timerData.isRestPaused
                          ? Colors.amber.withValues(alpha: 0.2)
                          : Colors.greenAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      timerData.isRestPaused ? 'PAUSED' : 'RESTING',
                      style: TextStyle(
                        color: timerData.isRestPaused ? Colors.amberAccent : Colors.greenAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Circular Countdown + Adjustment Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // -10 SECONDS BUTTON
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final timerProvider = context.read<WorkoutTimerProvider>();
                            timerProvider.addRestSeconds(-10);
                            if (timerProvider.restSecondsRemaining > 0) {
                              if (timerProvider.isRestPaused) {
                                _countDownController.pause();
                              } else {
                                _countDownController.restart(
                                  duration: timerProvider.restSecondsRemaining,
                                );
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.teal[900],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.teal[700]!, width: 1.5),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.remove_rounded, color: Colors.tealAccent, size: 22),
                                Text(
                                  '-10s',
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // CIRCULAR COUNTDOWN TIMER
                      CircularCountDownTimer(
                        controller: _countDownController,
                        width: MediaQuery.of(context).size.width / 2.6,
                        height: MediaQuery.of(context).size.width / 2.6,
                        duration: timerData.restSecondsRemaining,
                        initialDuration: 0,
                        fillColor: Colors.greenAccent,
                        ringColor: Colors.teal[700]!,
                        backgroundColor: Colors.teal[900],
                        strokeWidth: 14.0,
                        strokeCap: StrokeCap.round,
                        isReverse: true,
                        isReverseAnimation: true,
                        autoStart: timerData.isRestRunning && !timerData.isRestPaused,
                        textStyle: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                        textFormat: CountdownTextFormat.MM_SS,
                      ),

                      const SizedBox(width: 16),

                      // +10 SECONDS BUTTON
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final timerProvider = context.read<WorkoutTimerProvider>();
                            timerProvider.addRestSeconds(10);
                            if (timerProvider.isRestPaused) {
                              _countDownController.pause();
                            } else {
                              _countDownController.restart(
                                duration: timerProvider.restSecondsRemaining,
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.teal[900],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.teal[700]!, width: 1.5),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded, color: Colors.tealAccent, size: 22),
                                Text(
                                  '+10s',
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Control Action Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pause / Resume Toggle
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[900],
                          foregroundColor: Colors.tealAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          if (timerData.isRestPaused) {
                            context.read<WorkoutTimerProvider>().resumeRest();
                            _countDownController.resume();
                          } else {
                            context.read<WorkoutTimerProvider>().pauseRest();
                            _countDownController.pause();
                          }
                        },
                        icon: Icon(
                          timerData.isRestPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          color: Colors.tealAccent,
                          size: 22,
                        ),
                        label: Text(
                          timerData.isRestPaused ? 'Resume' : 'Pause',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Restart Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[900],
                          foregroundColor: Colors.tealAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          context.read<WorkoutTimerProvider>().restartRest(_totalRestDuration);
                          _countDownController.restart(duration: _totalRestDuration);
                        },
                        icon: const Icon(Icons.refresh_rounded, color: Colors.tealAccent, size: 22),
                        label: const Text(
                          'Restart',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
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
