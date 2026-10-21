import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/services/boss_battle_service.dart';
import 'package:fitness_slayer_01/services/sprite_animator.dart';

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

  @override
  Widget build(BuildContext context) {
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

              return Column(
                children: [
                  // TOP COMBAT STATUS BANNER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _battleService.currentMessage,
                            style: TextStyle(
                              color: AppColors.parchmentWhite,
                              fontSize: 14,
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // FIGHTING PLACE
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // SLAYER CARD
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: AppColors.hearthPanel,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSlayerTurn ? AppColors.gemGold : AppColors.woodFrame,
                                    width: isSlayerTurn ? 3.5 : 2,
                                  ),

                                  boxShadow: isSlayerTurn
                                      ? [
                                          BoxShadow(
                                            color: AppColors.gemGold.withValues(alpha: 0.4),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : [],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _battleService.slayerName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.gemGold,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Slayer Sprite
                                    // TODO: Slayer idle/attack sprite animation
                                    AspectRatio(
                                      aspectRatio: 1.0,
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.slateBackdrop,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSlayerTurn ? AppColors.gemGold : AppColors.brassBorder,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: SpriteAnimator.play(
                                            _battleService.slayerSpriteName,
                                            scale: 2.5,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Slayer Health Bar
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(Icons.favorite, color: Colors.greenAccent, size: 14),
                                                SizedBox(width: 4),
                                                Text('HP', style: TextStyle(color: AppColors.parchmentWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            Text(
                                              '${_battleService.slayerHp}/${_battleService.slayerMaxHp}',
                                              style: const TextStyle(color: AppColors.parchmentWhite, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: LinearProgressIndicator(
                                            value: _battleService.slayerHp / _battleService.slayerMaxHp,
                                            minHeight: 10,
                                            backgroundColor: AppColors.woodFrame,
                                            color: Colors.greenAccent,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Slayer Damage Label
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.woodFrame,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.flash_on, color: AppColors.gemGold, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            'DMG: ${_battleService.slayerDamage}',
                                            style: const TextStyle(
                                              color: AppColors.parchmentWhite,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // BOSS CARD
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: AppColors.hearthPanel,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isBossTurn ? AppColors.crimsonRed : AppColors.woodFrame,
                                    width: isBossTurn ? 3.5 : 2,
                                  ),
                                  boxShadow: isBossTurn
                                      ? [
                                          BoxShadow(
                                            color: AppColors.crimsonRed.withValues(alpha: 0.4),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : [],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _battleService.bossName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.crimsonRed,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Boss Sprite
                                    // TODO:  Boss idle/attack sprite animation
                                    AspectRatio(
                                      aspectRatio: 1.0,
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.slateBackdrop,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isBossTurn ? AppColors.crimsonRed : AppColors.brassBorder,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: SpriteAnimator.play(
                                            _battleService.bossSpriteName,
                                            scale: 2.5,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Boss Health Bar
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(Icons.favorite, color: AppColors.crimsonRed, size: 14),
                                                SizedBox(width: 4),
                                                Text('HP', style: TextStyle(color: AppColors.parchmentWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            Text(
                                              '${_battleService.bossHp}/${_battleService.bossMaxHp}',
                                              style: const TextStyle(color: AppColors.parchmentWhite, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: LinearProgressIndicator(
                                            value: _battleService.bossHp / _battleService.bossMaxHp,
                                            minHeight: 10,
                                            backgroundColor: AppColors.woodFrame,
                                            color: AppColors.crimsonRed,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Boss Damage Label
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.woodFrame,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.flash_on, color: AppColors.gemGold, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            'DMG: ${_battleService.bossDamage}',
                                            style: const TextStyle(
                                              color: AppColors.parchmentWhite,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
      ),
    );
  }
}
