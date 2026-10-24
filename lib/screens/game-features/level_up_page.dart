import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/providers/slayer_equipment_provider.dart';
import 'package:fitness_slayer_01/providers/EXP_bar.dart';
import 'package:fitness_slayer_01/services/database_service.dart';
import 'package:fitness_slayer_01/services/sprite_animator.dart';

import '../../services/audio_service.dart';

class LevelUpPage extends StatefulWidget {
  final bool isVictory;
  final String bossName;
  final int levelGained;

  const LevelUpPage({
    super.key,
    this.isVictory = true,
    this.bossName = 'NOSFERATU ZODD',
    this.levelGained = 1,
  });

  @override
  State<LevelUpPage> createState() => _LevelUpPageState();
}

class _LevelUpPageState extends State<LevelUpPage> {
  bool _hasAwardedXp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processBossBattleXp();
    });
  }

  // Fetches current user XP, calculates +30 XP reward if victorious,
  // updates Firestore, and triggers smooth EXP bar filling animation.
  Future<void> _processBossBattleXp() async {
    if (_hasAwardedXp || !mounted) return;
    _hasAwardedXp = true;

    final user = Provider.of<myUser?>(context, listen: false);
    final expBarProvider = Provider.of<ExpBarProvider>(context, listen: false);

    final uid = user?.uid ?? '';
    if (uid.isEmpty) return;

    try {
      final result = await DatabaseService().awardBossBattleXp(
        userId: uid,
        isVictory: widget.isVictory,
      );

      if (result == null || !mounted) return;

      // Set initial static EXP on bar
      expBarProvider.setStaticExp(result.initialXp, 100);

      if (result.earnedXp > 0) {
        // Animate +30 XP filling smoothly on the EXP bar and play level gain audio
        SoundService.playVictory(1200);
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          SoundService.playEXPGain(1200);
          expBarProvider.animateExpGain(result.initialXp, result.newXp, 100);
        }
      }
      else {
        SoundService.playDefeat(1200);
      }
    } catch (e) {
      debugPrint('Error processing boss battle XP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isVictory ? Colors.greenAccent : AppColors
        .crimsonRed;
    final equipmentState = context.watch<SlayerEquipmentProvider>();

    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.slateBackdrop,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Celebration Icon Badge
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.hearthPanel,
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.35),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.isVictory ? Icons.emoji_events : Icons
                        .sentiment_very_dissatisfied,
                    color: primaryColor,
                    size: 64,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  widget.isVictory ? 'BATTLE VICTORY!' : 'SLAYER DEFEATED',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  widget.isVictory
                      ? 'You have vanquished ${widget
                      .bossName} in glorious combat!'
                      : '${widget
                      .bossName} proved too formidable this time. Train harder to rise again!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.parchmentWhite,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                // EXP Bar Sprite positioned directly above the Slayer's head
                Consumer<ExpBarProvider>(
                  builder: (context, expBar, _) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                                Icons.star, color: AppColors.gemGold, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'EXP: ${expBar.currentExp} / ${expBar.maxExp}',
                              style: const TextStyle(
                                color: AppColors.parchmentWhite,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SpriteAnimator.play(
                            'bars/xp_bar_Sheet',
                            scale: 1,
                            frameCount: 8,
                            staticFrame: expBar.currentFrame,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Slayer Idle Sprite
                SpriteAnimator.play(
                  equipmentState.idleSpritePath,
                  scale: 6,
                ),

                const SizedBox(height: 28),

                // Return
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.flameOrange,
                      foregroundColor: AppColors.parchmentWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(
                        Icons.home, color: AppColors.parchmentWhite),
                    label: const Text(
                      'RETURN TO HUB',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}