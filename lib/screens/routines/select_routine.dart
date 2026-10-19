import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/models/routine.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import '../../services/database_service.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'routine_detail_screen.dart';

class SelectRoutineScreen extends StatelessWidget {
  const SelectRoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<myUser?>(context);
    final String currentUserId = user?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.slateBackdrop,

      // StreamBuilder listens to Firestore and rebuilds when data changes
      body: StreamBuilder<List<Routine>>(
        stream: currentUserId.isNotEmpty
            ? DatabaseService().getUserRoutines(currentUserId)
            : const Stream.empty(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.flameOrange));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading routines: ${snapshot.error}', style: const TextStyle(color: AppColors.crimsonRed)));
          }

          final routines = snapshot.data ?? [];

          if (routines.isEmpty) {
            return const Center(
              child: Text('No routines found', style: TextStyle(color: AppColors.brassBorder, fontSize: 18)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];

              return Card(
                color: AppColors.hearthPanel,
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.woodFrame, width: 1),
                ),
                child: ExpansionTile(
                  collapsedIconColor: AppColors.flameOrange,
                  iconColor: AppColors.flameOrange,
                  title: Text(
                    routine.routineName,
                    style: const TextStyle(color: AppColors.parchmentWhite, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${routine.exercises.length} Exercises',
                    style: const TextStyle(color: AppColors.brassBorder),
                  ),

                  // hidden until the user taps the tile
                  children: [
                    const Divider(color: AppColors.woodFrame),
                    ...routine.exercises.map((ex) => ListTile(
                      dense: true,
                      title: Text(ex.exerciseName, style: const TextStyle(color: AppColors.parchmentWhite)),
                      subtitle: Text('${ex.targetSets.length} Sets', style: const TextStyle(color: AppColors.brassBorder)),
                    )),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.flameOrange,
                            foregroundColor: AppColors.parchmentWhite,
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
