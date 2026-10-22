import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/widgets/bar_sprite.dart';
import 'package:fitness_slayer_01/services/database_service.dart';
import 'package:fitness_slayer_01/services/boss_battle_service.dart';
import 'package:fitness_slayer_01/services/sprite_animator.dart';

import '../../providers/slayer_equipment_provider.dart';

class BossBattleScreen extends StatefulWidget {
  const BossBattleScreen({super.key});

  @override
  State<BossBattleScreen> createState() => _BossBattleScreenState();
}

class _BossBattleScreenState extends State<BossBattleScreen> {
  // Instance of the combat service that holds all character stats, turns, and fight logic.
  final BossBattleService _battleService = BossBattleService();

  @override
  void dispose() {
    _battleService.dispose();
    super.dispose();
  }

  // Takes the phase and gives it color depending on who's turn it currently is
  Color _getPhaseColor(BattlePhase phase) {
    switch (phase) {
      case BattlePhase.slayerAttacking:
        return AppColors.gemGold;
      case BattlePhase.bossAttacking:
        return AppColors.crimsonRed;
      case BattlePhase.victory:
        return Colors.greenAccent;
      case BattlePhase.defeat:
      case BattlePhase.idle:
        return AppColors.brassBorder;
    }
  }

  // Icons depending on who's phase it is
  IconData _getPhaseIcon(BattlePhase phase) {
    switch (phase) {
      case BattlePhase.slayerAttacking:
        return Icons.flash_on;
      case BattlePhase.bossAttacking:
        return Icons.shield;
      case BattlePhase.victory:
        return Icons.emoji_events;
      case BattlePhase.defeat:
        return Icons.sentiment_very_dissatisfied;
      case BattlePhase.idle:
        return Icons.sports_kabaddi;
    }
  }

  // Helper widget to build the left/right status HUD for Slayer and Boss
  Widget _buildSideHud({
    required String name,
    required Color nameColor,
    required int hp,
    required int maxHp,
    required int damage,
    required Color barColor,
    required bool isTurn,
  }) {
    final double hpRatio = maxHp > 0 ? (hp / maxHp).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name with active turn indicator
        Row(
          children: [
            Icon(
              isTurn ? Icons.play_arrow : Icons.person,
              color: isTurn ? nameColor : AppColors.parchmentWhite.withValues(alpha: 0.6),
              size: 14,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: nameColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // HP bar & numerical ratio
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: barColor, size: 12),
                const SizedBox(width: 4),
                const Text(
                  'HP',
                  style: TextStyle(
                    color: AppColors.parchmentWhite,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              '$hp/$maxHp',
              style: const TextStyle(
                color: AppColors.parchmentWhite,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // PIXEL ART HP BAR SPRITE
        SizedBox(
          width: double.infinity,
          height: 18,
          child: BarSpriteWidget(
            barName: 'hp_bar_Sheet',
            frameCount: 5,
            progress: hpRatio,
            isAttackBar: false,
          ),
        ),

        const SizedBox(height: 8),

        // ATK & DMG Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isTurn ? 'ATTACKING...' : 'ATK',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isTurn ? AppColors.gemGold : AppColors.parchmentWhite,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'DMG: $damage',
              style: const TextStyle(
                color: AppColors.gemGold,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),

        // PIXEL ART ATTACK BAR SPRITE
        SizedBox(
          width: double.infinity,
          height: 25,
          child: BarSpriteWidget(
            barName: 'attack_bar_Sheet',
            frameCount: 5,
            isAttackBar: true,
            isTurn: isTurn,
            drainDuration: const Duration(milliseconds: 2000),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<myUser?>(context);
    final uid = user?.uid ?? '';
    final equipmentState = context.watch<SlayerEquipmentProvider>();


    return StreamBuilder<BossBattleData>(
      stream: DatabaseService().getBossBattleDataStream(uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          _battleService.updateProgressionStats(
            slayerLevel: data.level,
            weekNumber: data.weekNumber,
            slayerNameInput: data.slayerName,
          );
        }

        return Scaffold(
          appBar: const MyAppBar(),
          backgroundColor: AppColors.slateBackdrop,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: ListenableBuilder(
                listenable: _battleService,
                builder: (context, _) {
                  final isSlayerTurn = _battleService.phase == BattlePhase.slayerAttacking;
                  final isBossTurn = _battleService.phase == BattlePhase.bossAttacking;

                  final currentSlayerSprite = isSlayerTurn
                      ? equipmentState.attackSpritePath
                      : equipmentState.idleSpritePath;

                  return Column(
                    children: [
                      // TOP COMBAT STATUS BANNER
                      SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.hearthPanel,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getPhaseColor(_battleService.phase),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getPhaseColor(_battleService.phase).withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getPhaseIcon(_battleService.phase),
                                color: _getPhaseColor(_battleService.phase),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _battleService.currentMessage,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.parchmentWhite,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(alpha: 0.5),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // TOP HALF COMBAT ARENA
                      Expanded(
                        flex: 5,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.hearthPanel,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.woodFrame, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              children: [
                                // ANIMATED DUNGEON BACKGROUND SPRITESHEET
                                Positioned.fill(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    alignment: Alignment.bottomCenter,
                                    clipBehavior: Clip.hardEdge,
                                    child: SpriteAnimator.play(
                                      'backgrounds/dungeon_background_spritesheet',
                                      scale: 1.0,
                                      fps: 8,
                                      pingPong: false,
                                      frameCount: 6,
                                    ),
                                  ),
                                ),

                                // ARENA GRADIENT
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.25),
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.35),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // OVERLAY SPRITES STANDING DIRECTLY IN DUNGEON HALLWAY
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: 54,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Slayer Sprite (Knight - half the height of boss)
                                      AnimatedScale(
                                        scale: isSlayerTurn ? 1.15 : 1.0,
                                        duration: const Duration(milliseconds: 300),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: SpriteAnimator.play(
                                            currentSlayerSprite,
                                            scale: 2.8,
                                          ),
                                        ),
                                      ),

                                      // Boss Sprite
                                      Flexible(
                                        child: AnimatedScale(
                                          scale: isBossTurn ? 1.12 : 1.0,
                                          duration: const Duration(milliseconds: 300),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: SpriteAnimator.play(
                                              _battleService.bossSpriteName,
                                              scale: 1.8,
                                            ),
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
                      ),

                      const SizedBox(height: 12),

                      // BOTTOM HALF STATUS HUD PANEL
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: AppColors.hearthPanel,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getPhaseColor(_battleService.phase),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // LEFT SIDE: SLAYER HUD
                            Expanded(
                              child: _buildSideHud(
                                name: _battleService.slayerName,
                                nameColor: AppColors.gemGold,
                                hp: _battleService.slayerHp,
                                maxHp: _battleService.slayerMaxHp,
                                damage: _battleService.slayerDamage,
                                barColor: Colors.greenAccent,
                                isTurn: isSlayerTurn,
                              ),
                            ),

                            const SizedBox(width: 12),

                            // VERTICAL DIVIDER
                            Container(
                              width: 1,
                              height: 75,
                              color: AppColors.woodFrame,
                            ),

                            const SizedBox(width: 12),

                            // RIGHT SIDE: BOSS HUD
                            Expanded(
                              child: _buildSideHud(
                                name: _battleService.bossName,
                                nameColor: AppColors.crimsonRed,
                                hp: _battleService.bossHp,
                                maxHp: _battleService.bossMaxHp,
                                damage: _battleService.bossDamage,
                                barColor: AppColors.crimsonRed,
                                isTurn: isBossTurn,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // START BATTLE BUTTON
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
                            elevation: 3,
                          ),
                          icon: Icon(
                            _battleService.isBattleActive
                                ? Icons.hourglass_top
                                : Icons.play_arrow,
                            color: AppColors.parchmentWhite,
                          ),
                          label: Text(
                            _battleService.isBattleActive
                                ? 'BATTLE IN PROGRESS...'
                                : 'START BATTLE',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: AppColors.parchmentWhite,
                            ),
                          ),
                          onPressed: _battleService.isBattleActive
                              ? null
                              : () {
                                  _battleService.startBattleScript();
                                },
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  );
                },
              ),
            ),
          )
        );
        },
      );
  }
}
