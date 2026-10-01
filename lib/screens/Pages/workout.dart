import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/widgets/exercise_card.dart';
import 'package:fitness_slayer_01/models/exercises.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  List<Exercise> currentWorkoutExercises = [];

  void _showExercisePicker() async {
    List<Exercise> allExercises = await Exercise.loadExercises();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.teal[800],
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                    'Select Exercise',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: allExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = allExercises[index];
                    return ListTile(
                      title: Text(exercise.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(exercise.primaryMuscles.join(', '), style: const TextStyle(color: Colors.white54)),
                      trailing: const Icon(Icons.add_circle_outline, color: Colors.greenAccent),
                      onTap: () {
                        setState(() {
                          currentWorkoutExercises.add(exercise);
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: 'John Doe Lv.21',
      ),
      backgroundColor: Colors.teal[900],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              ...currentWorkoutExercises.asMap().entries.map((entry) {
                int index = entry.key;
                Exercise exercise = entry.value;

                return ExerciseCard(
                  exerciseName: exercise.name,
                  exerciseId: exercise.id,
                  onDelete: () {
                    setState(() {
                      currentWorkoutExercises.removeAt(index);
                    });
                  },
                );
              }),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _showExercisePicker,
                child: const Text('Add Exercise'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}