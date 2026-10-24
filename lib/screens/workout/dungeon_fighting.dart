import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import '../../providers/slayer_equipment_provider.dart';
import 'package:fitness_slayer_01/services/sprite_animator.dart';

class DungeonScene extends StatelessWidget {
  const DungeonScene({super.key});

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
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SpriteAnimator.play(
                  'backgrounds/dungeon_background_spritesheet',
                  scale: 1.0,
                  fps: 8,
                  pingPong: false,
                  frameCount: 6,
                ),
              ),
            ),

            const Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: Text(
                'HOLDING THEM OFF SIRE!',
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
              left: 40,
              bottom: 25,
              child: AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 300),
                child: SpriteAnimator.play(
                  equipmentState.attackSpritePath,
                  scale: 2.0,
                ),
              ),
            ),

            // Slime
            Positioned(
              right: 120,
              bottom: 25,
              child: AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 300),
                child: SpriteAnimator.play(
                  'attack/slime_attack_spritesheet',
                  scale: 0.22,
                ),
              ),
            ),

            // Wisp (Flying)
            Positioned(
              right: 40,
              bottom: 75,
              child: AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 300),
                child: SpriteAnimator.play(
                  'attack/wisp_attack_spritesheet',
                  scale: 0.22,
                ),
              ),
            ),

            // Ghost
            Positioned(
              right: 80,
              bottom: 20,
              child: AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 300),
                child: SpriteAnimator.play(
                  'attack/ghost_attack_spritesheet',
                  scale: 0.14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}