import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';

class BmiCalculator extends StatelessWidget {
  const BmiCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      backgroundColor: AppColors.obsidianBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'BMI Calculator',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}