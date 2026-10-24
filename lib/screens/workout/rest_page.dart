import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/timers/rest_timer.dart';
import 'dungeon_fighting.dart';

class RestTimerScreen extends StatelessWidget {
  const RestTimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.slateBackdrop,
      body: const Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
            child: TimerWidget(),
          ),

          Expanded(
            flex: 10,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: DungeonScene(),
            ),
          ),

          Spacer(flex: 5),
        ],
      ),
    );
  }
}