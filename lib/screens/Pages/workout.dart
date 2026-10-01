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

  // Cache list of exercises so we only load the JSON once
  List<Exercise> _cachedAllExercises = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }


  Future<void> _loadInitialData() async {
    _cachedAllExercises = await Exercise.loadExercises();
  }

  // List of all exercises
  // TODO Make a filtering system, right now just returning entire json with all exercises- too long
  // TODO Move styles into global styling- less clutter
  void _showExercisePicker() {
    if (_cachedAllExercises.isEmpty) return;

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
                  itemCount: _cachedAllExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _cachedAllExercises[index];
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