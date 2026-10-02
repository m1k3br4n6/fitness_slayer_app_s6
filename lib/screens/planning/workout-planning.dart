import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/screens/Pages/workout.dart';

class WorkoutPlanning extends StatelessWidget {
  const WorkoutPlanning({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'John Doe Lv.21'),
      backgroundColor: Colors.teal[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutScreen()),
                );
              },
              child: const Text('New Workout'),
            ),
            ElevatedButton(
              onPressed: (){

              },
              child: const Text('Select From Routines')),
          ],
        ),
      ),
    );
  }
}
