import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:fitness_slayer_01/providers/workout_timer.dart';
import '../../providers/slayer_equipment_provider.dart';
import '../../services/ambient_battle_service.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/campsite_scene.dart';
import '../../widgets/timers/rest_timer.dart';
import 'dungeon_fighting.dart';

class RestTimerScreen extends StatefulWidget {
  const RestTimerScreen({super.key});

  @override
  State<RestTimerScreen> createState() => _RestTimerScreenState();
}

class _RestTimerScreenState extends State<RestTimerScreen> {
  @override
  void initState() {
    super.initState();

    // Read providers after screen build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final equipment = Provider.of<SlayerEquipmentProvider>(context, listen: false).equippedClass;
      final timerData = Provider.of<WorkoutTimerProvider>(context, listen: false);

      // start fighting if timer not null or paused
      if (!timerData.isRestPaused) {
        AmbientBattleService.startAmbientCombat(equipment);
      }
    });
  }

  @override
  void dispose() {
    // Stop battle if user leaves page
    AmbientBattleService.stopAmbientCombat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final timerData = context.watch<WorkoutTimerProvider>();

    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.slateBackdrop,
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
            child: TimerWidget(),
          ),

          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              // if rest is paused swap scenes
              child: timerData.isRestPaused
                  ? const CampsiteScene()
                  : const DungeonScene(),
            ),
          ),

          const Spacer(flex: 5),
        ],
      ),
    );
  }
}