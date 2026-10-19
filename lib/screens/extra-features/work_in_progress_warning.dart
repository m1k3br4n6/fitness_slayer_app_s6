import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';

import '../../theme/app_colors.dart';

class WorkInProgressWarning extends StatelessWidget {
  const WorkInProgressWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.obsidianBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber,
              size: 90,
            ),
            const Text(
              'Halt! Turn back!',
              style: TextStyle(color: AppColors.parchmentWhite, fontSize: 35),
            ),
            const Text(
              'Sorry, this page is still under construction.',
              style: TextStyle(color: AppColors.parchmentWhite, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
