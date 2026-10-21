import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';

class BossBattleScreen extends StatefulWidget {
  const BossBattleScreen({super.key});

  @override
  State<BossBattleScreen> createState() => _BossBattleScreenState();
}

class _BossBattleScreenState extends State<BossBattleScreen> {
  // temp stats
  int slayerHp = 100;
  int slayerMaxHp = 100;
  int slayerDamage = 20;

  int bossHp = 100;
  int bossMaxHp = 100;
  int bossDamage = 15;

  void _startBattle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.hearthPanel,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.gemGold, width: 1.5),
        ),
        content: const Row(
          children: [
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Battle Started!',
                style: TextStyle(
                  color: AppColors.parchmentWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.slateBackdrop,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //SLAYER
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: AppColors.hearthPanel,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.woodFrame, width: 2),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  //TODO Import actual name
                                  'SLAYER NAME',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.gemGold,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // SLAYER SPRITE
                                AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.slateBackdrop,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.gemGold, width: 1.5),
                                    ),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person, color: AppColors.gemGold, size: 44),
                                        SizedBox(height: 6),
                                        Text(
                                          //TODO IMPORT SLAYER SPRITE
                                          'SLAYER HERE',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppColors.gemGold,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Slayer HP Label
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.woodFrame,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.favorite, color: Colors.greenAccent, size: 16),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'HP: $slayerHp/$slayerMaxHp',
                                          style: const TextStyle(
                                            color: AppColors.parchmentWhite,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Slayer Damage Label
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.woodFrame,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.flash_on, color: AppColors.gemGold, size: 16),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'Damage: $slayerDamage',
                                          style: const TextStyle(
                                            color: AppColors.parchmentWhite,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
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

                        const SizedBox(width: 10),

                        // BOSS TEMPLATE
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: AppColors.hearthPanel,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.woodFrame, width: 2),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Boss Name Header
                                const Text(
                                  //TODO BOSS NAME IMPORT
                                  'BOSS NAME',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.crimsonRed,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // BOSS SPRITE
                                AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.slateBackdrop,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.crimsonRed, width: 1.5),
                                    ),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person, color: AppColors.crimsonRed, size: 44),
                                        SizedBox(height: 6),
                                        Text(
                                          'BOSS HERE',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppColors.crimsonRed,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Boss HP Label
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.woodFrame,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.favorite, color: AppColors.crimsonRed, size: 16),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'HP: $bossHp/$bossMaxHp',
                                          style: const TextStyle(
                                            color: AppColors.parchmentWhite,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Boss Damage Label
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.woodFrame,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.flash_on, color: AppColors.gemGold, size: 16),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'Damage: $bossDamage',
                                          style: const TextStyle(
                                            color: AppColors.parchmentWhite,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
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
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              //START BUTTON
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
                  label: const Text(
                    //TODO HERE WE KICK OF THE SCRIPT FOR THE FIGHT
                    'START BATTLE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: AppColors.parchmentWhite,
                    ),
                  ),
                  onPressed: _startBattle,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
