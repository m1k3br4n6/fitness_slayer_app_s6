import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:fitness_slayer_01/providers/workout_timer.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  final CountDownController _countDownController = CountDownController();
  final int _totalRestDuration = 120;

  @override
  Widget build(BuildContext context) {
    final timerData = context.watch<WorkoutTimerProvider>();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.hearthPanel,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.timer_outlined, color: AppColors.gemGold, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Rest Timer',
                    style: TextStyle(
                      color: AppColors.parchmentWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: timerData.isRestPaused
                      ? AppColors.gemGold.withValues(alpha: 0.2)
                      : AppColors.flameOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  timerData.isRestPaused ? 'PAUSED' : 'RESTING',
                  style: TextStyle(
                    color: timerData.isRestPaused ? AppColors.gemGold : AppColors.flameOrange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTimeAdjustButton('-10s', Icons.remove_rounded, () {
                final timerProvider = context.read<WorkoutTimerProvider>();
                timerProvider.addRestSeconds(-10);
                if (timerProvider.restSecondsRemaining > 0) {
                  if (timerProvider.isRestPaused) {
                    _countDownController.pause();
                  } else {
                    _countDownController.restart(duration: timerProvider.restSecondsRemaining);
                  }
                }
              }),
              const SizedBox(width: 20),
              CircularCountDownTimer(
                controller: _countDownController,
                width: 100,
                height: 100,
                duration: timerData.restSecondsRemaining,
                initialDuration: 0,
                fillColor: AppColors.flameOrange,
                ringColor: AppColors.woodFrame,
                backgroundColor: AppColors.slateBackdrop,
                strokeWidth: 8.0,
                strokeCap: StrokeCap.round,
                isReverse: true,
                isReverseAnimation: true,
                autoStart: timerData.isRestRunning && !timerData.isRestPaused,
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.parchmentWhite,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
                textFormat: CountdownTextFormat.MM_SS,
              ),
              const SizedBox(width: 20),
              _buildTimeAdjustButton('+10s', Icons.add_rounded, () {
                final timerProvider = context.read<WorkoutTimerProvider>();
                timerProvider.addRestSeconds(10);
                if (timerProvider.isRestPaused) {
                  _countDownController.pause();
                } else {
                  _countDownController.restart(duration: timerProvider.restSecondsRemaining);
                }
              }),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: timerData.isRestPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                label: timerData.isRestPaused ? 'Resume' : 'Pause',
                onTap: () {
                  if (timerData.isRestPaused) {
                    context.read<WorkoutTimerProvider>().resumeRest();
                    _countDownController.resume();
                  } else {
                    context.read<WorkoutTimerProvider>().pauseRest();
                    _countDownController.pause();
                  }
                },
              ),
              const SizedBox(width: 12),
              _buildControlButton(
                icon: Icons.refresh_rounded,
                label: 'Restart',
                onTap: () {
                  context.read<WorkoutTimerProvider>().restartRest(_totalRestDuration);
                  _countDownController.restart(duration: _totalRestDuration);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeAdjustButton(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.slateBackdrop,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.brassBorder, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.gemGold, size: 20),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.gemGold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.woodFrame,
        foregroundColor: AppColors.parchmentWhite,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.gemGold, size: 20),
      label: Text(
        label,
        style: const TextStyle(
          color: AppColors.parchmentWhite,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}