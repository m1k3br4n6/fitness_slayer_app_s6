import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';

class SideQuest extends StatelessWidget {
  const SideQuest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: 'John Doe Lv.21',
      ),
      backgroundColor: Colors.teal[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Side Quest - Daily Challenge Page',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
