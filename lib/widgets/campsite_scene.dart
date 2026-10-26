import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import '../../providers/slayer_equipment_provider.dart';
import 'package:fitness_slayer_01/services/sprite_animator.dart';

class CampsiteScene extends StatefulWidget {
  final bool playAudio;
  final bool showText;
  final bool showExpBar;
  final int xp;
  final int xpNeeded;
  final int xpFrame;

  const CampsiteScene({
    super.key,
    this.playAudio = true,
    this.showText = true,
    this.showExpBar = false,
    this.xp = 0,
    this.xpNeeded = 100,
    this.xpFrame = 0,
  });

  @override
  State<CampsiteScene> createState() => _CampsiteSceneState();
}

class _CampsiteSceneState extends State<CampsiteScene> {
  final AudioPlayer _campsitePlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    if (widget.playAudio) {
      _campsitePlayer.setReleaseMode(ReleaseMode.loop);
      _campsitePlayer.play(AssetSource('sounds/campfire.wav'));
    }
  }

  @override
  void dispose() {
    if (widget.playAudio) {
      _campsitePlayer.stop();
      _campsitePlayer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final equipmentState = context.watch<SlayerEquipmentProvider>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              child: SizedBox(
                width: 420,
                height: 240,
                child: Stack(
                  children: [
                    // BACKGROUND
                    Positioned.fill(
                      child: SpriteAnimator.play(
                        'backgrounds/campsite_background_spritesheet',
                        scale: 1.0,
                        fps: 8,
                        pingPong: false,
                        frameCount: 6,
                      ),
                    ),

                    // SLAYER (IDLE)
                    Positioned(
                      left: 120,
                      bottom: 30,
                      child: AnimatedOpacity(
                        opacity: equipmentState.isLoading ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        child: AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: SpriteAnimator.play(
                            equipmentState.idleSpritePath,
                            scale: 2.0,
                          ),
                        ),
                      ),
                    ),

                    // EXP BAR
                    if (widget.showExpBar)
                      Positioned(
                        left: 120,
                        bottom: 85,
                        width: 50,
                        height: 16,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          alignment: Alignment.centerLeft,
                          child: SpriteAnimator.play(
                            'bars/xp_bar_Sheet',
                            scale: 0.5,
                            frameCount: 8,
                            staticFrame: widget.xpFrame,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (widget.showText)
              const Positioned(
                top: 16,
                left: 20,
                right: 20,
                child: Text(
                  'Welcome Home, Great Slayer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.parchmentWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}