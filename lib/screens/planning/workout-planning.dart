import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/screens/Pages/workout.dart';

class WorkoutPlanning extends StatefulWidget {
  const WorkoutPlanning({super.key});

  @override
  State<WorkoutPlanning> createState() => _WorkoutPlanningState();
}

class _WorkoutPlanningState extends State<WorkoutPlanning> {
  bool _isExpanded = false;

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[900],
      body: Stack(
        children: [
          if (_isExpanded)
            GestureDetector(
              onTap: _toggleMenu,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isExpanded) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[800],
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.add, color: Colors.tealAccent),
              label: const Text('New Workout', style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () {
                _toggleMenu();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[800],
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.list_alt, color: Colors.tealAccent),
              label: const Text('Select From Routines', style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () {
                _toggleMenu();
              },
            ),
            const SizedBox(height: 16),
          ],
          FloatingActionButton(
            backgroundColor: Colors.teal[800],
            foregroundColor: Colors.tealAccent,
            shape: const CircleBorder(),
            onPressed: _toggleMenu,
            child: Icon(_isExpanded ? Icons.close : Icons.fitness_center),
          ),
        ],
      ),
    );
  }
}