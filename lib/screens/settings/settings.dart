import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import '../../theme/app_colors.dart';

class AppSettings extends StatelessWidget {
  const AppSettings({super.key});

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
              'Settings Page',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
