import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';

class Slayer extends StatelessWidget {
  const Slayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.obsidianBlack,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Slayer Page',
              style: TextStyle(color: AppColors.parchmentWhite, fontSize: 20),
            ),
          ],        ),
      ),
    );
  }
}