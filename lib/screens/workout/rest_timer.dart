import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/providers/workout_timer.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';

import '../../providers/slayer_equipment_provider.dart';
import '../../widgets/app_bar.dart';

//Sprite Animator
import 'package:fitness_slayer_01/services/sprite_animator.dart';

const double dungeonHeight = 300;

class RestTimerCard extends StatefulWidget {
  const RestTimerCard({super.key});

  @override
  State<RestTimerCard> createState() => _RestTimerCardState();
}

class _RestTimerCardState extends State<RestTimerCard> {
  final CountDownController _countDownController = CountDownController();

  final int _totalRestDuration = 120;

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: AppColors.hearthPanel,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerData = context.watch<WorkoutTimerProvider>();

    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.slateBackdrop,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // timer tile
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
              child: _buildTimerCard(timerData),
            ),

            // dungeon tile
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 24.0),
              child: _buildDungeonContainer(),
            ),
          ],
        ),
      ),
    );
  }

  //timer tile
  Widget _buildTimerCard(WorkoutTimerProvider timerData) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: _panelDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // timer title
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined, color: AppColors.gemGold, size: 28),
              SizedBox(width: 10),
              Text(
                'Rest Timer',
                style: TextStyle(
                  color: AppColors.parchmentWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // timer status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: timerData.isRestPaused
                  ? AppColors.gemGold.withValues(alpha: 0.2)
                  : AppColors.flameOrange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              timerData.isRestPaused ? 'PAUSED' : 'RESTING',
              style: TextStyle(
                color: timerData.isRestPaused
                    ? AppColors.gemGold
                    : AppColors.flameOrange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // circular countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // -10 sec button
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
                      color: AppColors.slateBackdrop,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.brassBorder,
                        width: 1.5,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_rounded,
                          color: AppColors.gemGold,
                          size: 22,
                        ),
                        Text(
                          '-10s',
                          style: TextStyle(
                            color: AppColors.gemGold,
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

              // countdown timer
              CircularCountDownTimer(
                controller: _countDownController,
                width: MediaQuery.of(context).size.width / 2.6,
                height: MediaQuery.of(context).size.width / 2.6,
                duration: timerData.restSecondsRemaining,
                initialDuration: 0,
                fillColor: AppColors.flameOrange,
                ringColor: AppColors.woodFrame,
                backgroundColor: AppColors.slateBackdrop,
                strokeWidth: 14.0,
                strokeCap: StrokeCap.round,
                isReverse: true,
                isReverseAnimation: true,
                autoStart: timerData.isRestRunning && !timerData.isRestPaused,
                textStyle: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.parchmentWhite,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
                textFormat: CountdownTextFormat.MM_SS,
              ),

              const SizedBox(width: 16),

              // +10 sec button
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
                      color: AppColors.slateBackdrop,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.brassBorder,
                        width: 1.5,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          color: AppColors.gemGold,
                          size: 22,
                        ),
                        Text(
                          '+10s',
                          style: TextStyle(
                            color: AppColors.gemGold,
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

          // controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // pause/ resume
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.woodFrame,
                  foregroundColor: AppColors.parchmentWhite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
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
                  timerData.isRestPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  color: AppColors.gemGold,
                  size: 22,
                ),
                label: Text(
                  timerData.isRestPaused ? 'Resume' : 'Pause',
                  style: const TextStyle(
                    color: AppColors.parchmentWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Restart Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.woodFrame,
                  foregroundColor: AppColors.parchmentWhite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  context.read<WorkoutTimerProvider>().restartRest(
                    _totalRestDuration,
                  );
                  _countDownController.restart(duration: _totalRestDuration);
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.gemGold,
                  size: 22,
                ),
                label: const Text(
                  'Restart',
                  style: TextStyle(
                    color: AppColors.parchmentWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // mini game

  Widget _buildDungeonContainer() {

    final equipmentState = context.watch<SlayerEquipmentProvider>();

    return Container(
      decoration: _panelDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),

        child: SizedBox(
          width: double.infinity,
          height: dungeonHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SpriteAnimator.play(
                'backgrounds/dungeon_background_spritesheet',
                scale: 1.2,
                fps: 8,
                pingPong: false,
                frameCount: 6,
              ),

              //welcome text
              const Positioned(
                top: 30,
                left: 20,
                right: 20,
                child: Text(
                  'HOLDING THEM OFF SIRE!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.parchmentWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              //Slayer Sprite
              Positioned(
                left: 90,
                right: 16,
                bottom: 54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SpriteAnimator.play(
                          equipmentState.attackSpritePath,
                          scale: 1.9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //enemy sprite 1
              Positioned(
                left: 150,
                right: 16,
                bottom: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SpriteAnimator.play(
                          'attack/slime_attack_spritesheet',
                          scale: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //enemy sprite 2
              Positioned(
                left: 260,
                right: 16,
                bottom: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SpriteAnimator.play(
                          'attack/wisp_attack_spritesheet',
                          scale: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //enemy sprite 3
              Positioned(
                left: 230,
                right: 16,
                bottom: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SpriteAnimator.play(
                          'attack/ghost_attack_spritesheet',
                          scale: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
