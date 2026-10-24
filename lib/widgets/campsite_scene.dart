import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import '../../providers/slayer_equipment_provider.dart';
import 'package:fitness_slayer_01/services/sprite_animator.dart';

class CampsiteScene extends StatefulWidget {
  const CampsiteScene({super.key});

  @override
  State<CampsiteScene> createState() => _CampsiteSceneState();
}

class _CampsiteSceneState extends State<CampsiteScene> {
  final AudioPlayer _campsitePlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _campsitePlayer.setReleaseMode(ReleaseMode.loop);
    _campsitePlayer.play(AssetSource('sounds/campfire.wav'));
  }

  @override
  void dispose() {
    // Stops the sound when use clicks resume
    _campsitePlayer.stop();
    _campsitePlayer.dispose();
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
            // BACKGROUND
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SpriteAnimator.play(
                  'backgrounds/campsite_background_spritesheet',
                  scale: 1.0,
                  fps: 8,
                  pingPong: false,
                  frameCount: 6,
                ),
              ),
            ),

            // WELCOME TEXT
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

            // SLAYER
            Positioned(
              left: 120,
              bottom: 55,
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
          ],
        ),
      ),
    );
  }
}