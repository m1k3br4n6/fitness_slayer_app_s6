import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/models/routine.dart';
import '../../services/database_service.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'routine_detail_screen.dart';

class SelectRoutineScreen extends StatelessWidget {
  const SelectRoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String currentUserId = 'Bernard'; // TODO: AUTH TEAM

    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: Colors.teal[900],

      // StreamBuilder listens to Firestore and rebuilds when data changes
      body: StreamBuilder<List<Routine>>(
        stream: DatabaseService().getUserRoutines(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading routines: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
          }

          final routines = snapshot.data ?? [];

          if (routines.isEmpty) {
            return const Center(
              child: Text('No routines found', style: TextStyle(color: Colors.white70, fontSize: 18)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];

              return Card(
                color: Colors.teal[800],
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  collapsedIconColor: Colors.greenAccent,
                  iconColor: Colors.greenAccent,
                  title: Text(
                    routine.routineName,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${routine.exercises.length} Exercises',
                    style: const TextStyle(color: Colors.white54),
                  ),

                  // hidden until the user taps the tile
                  children: [
                    const Divider(color: Colors.teal),
                    ...routine.exercises.map((ex) => ListTile(
                      dense: true,
                      title: Text(ex.exerciseName, style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${ex.targetSets.length} Sets', style: const TextStyle(color: Colors.white54)),
                    )),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.teal[900],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                             builder: (context) => RoutineDetailScreen(routine: routine),
                            ));
                          },
                          child: const Text('OPEN ROUTINE', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}