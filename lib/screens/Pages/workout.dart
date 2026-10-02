import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/widgets/exercise_card.dart';
import 'package:fitness_slayer_01/models/exercises.dart';
import 'package:fitness_slayer_01/widgets/exercise_search.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  List<Exercise> currentWorkoutExercises = [];

  Future<void> _navigateAndAddExercise() async {
    final selectedExercise = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExerciseSearchScreen(),
      ),
    );

    // If the user picked an exercise add it
    if (selectedExercise != null && mounted) {
      setState(() {
        currentWorkoutExercises.add(selectedExercise);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO Change to actual user name
      appBar: const MyAppBar(
        title: 'John Doe Lv.21',
      ),
      backgroundColor: Colors.teal[900],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              //Spread operator lets line read from right to left and after each entry has been mapped with its
              // own key value pair the ... lets each container be its own widget so that each of the objects gets mapped
              // and displayed properly
              ...currentWorkoutExercises.asMap().entries.map((entry) {
                int index = entry.key;
                Exercise exercise = entry.value;

                return ExerciseCard(
                  exerciseId: exercise.id,
                  exerciseName: exercise.name,
                  primaryMuscles: exercise.primaryMuscles,
                  mechanic: exercise.mechanic,
                  force: exercise.force,
                  instructions: exercise.instructions,
                  onDelete: () {
                    setState(() {
                      currentWorkoutExercises.removeAt(index);
                    });
                  },
                );
              }),

              const SizedBox(height: 20),

              // TODO Make it look more nicer, right now just for testing
              ElevatedButton(
                onPressed: _navigateAndAddExercise,
                child: const Text('Add Exercise'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}