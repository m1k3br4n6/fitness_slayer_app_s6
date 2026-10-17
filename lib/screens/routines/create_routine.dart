import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/models/exercises.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/widgets/exercise_search.dart';
import 'package:fitness_slayer_01/widgets/cards/routine_exercise_card.dart';

import '../../models/routine.dart';
import '../../services/database_service.dart';

class CreateRoutineScreen extends StatefulWidget {
  final Routine? initialRoutine;

  const CreateRoutineScreen({super.key, this.initialRoutine});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  bool _isSubmitting = false;
  bool _isLoadingInitialData = false;

  // Controller for routine name
  final TextEditingController _routineNameController = TextEditingController();

  // Local state for routine exercises to completely separate from active workout session
  final List<RoutineExerciseData> _routineExercises = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialRoutine != null) {
      _routineNameController.text = widget.initialRoutine!.routineName;
      _loadInitialRoutineData();
    }
  }

  Future<void> _loadInitialRoutineData() async {
    setState(() {
      _isLoadingInitialData = true;
    });

    try {
      final String jsonString = await rootBundle.loadString('assets/exercises.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      for (var routineEx in widget.initialRoutine!.exercises) {
        final matchingJson = jsonData.firstWhere(
          (jsonEx) => jsonEx['id'] == routineEx.exerciseId,
          orElse: () => null,
        );

        if (matchingJson == null) continue;

        final fullExercise = Exercise.fromJson(matchingJson);
        final sets = routineEx.targetSets.map((s) {
          return RoutineSetData(
            weight: s.targetWeight == 0 ? '' : s.targetWeight.toString(),
            reps: s.targetReps == 0 ? '' : s.targetReps.toString(),
          );
        }).toList();

        _routineExercises.add(
          RoutineExerciseData(
            exercise: fullExercise,
            sets: sets.isEmpty ? [RoutineSetData(), RoutineSetData()] : sets,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading initial routine data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _routineNameController.dispose();
    super.dispose();
  }

  Future<void> _navigateAndAddExercise() async {
    final selectedExercise = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExerciseSearchScreen(),
      ),
    );

    if (selectedExercise != null && mounted) {
      setState(() {
        _routineExercises.add(
          RoutineExerciseData(
            exercise: selectedExercise,
            sets: [
              RoutineSetData(),
              RoutineSetData(),
            ],
          ),
        );
      });
    }
  }

  Future<void> _saveRoutine() async {
    final user = context.read<myUser?>();
    final String currentUserId = user?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to save a routine.')),
      );
      return;
    }

    // Validation needs name and at least one exercise
    if (_routineNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give your routine a name')),
      );
      return;
    }

    if (_routineExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add some exercises to your routine!')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Map local routine exercise data into the Routine model
    final newRoutine = Routine(
      routineName: _routineNameController.text.trim(),
      exercises: _routineExercises.map((routineEx) {
        return RoutineExercise(
          exerciseId: routineEx.exercise.id,
          exerciseName: routineEx.exercise.name,
          targetSets: routineEx.sets.asMap().entries.map((entry) {
            return RoutineSet(
              setNumber: entry.key + 1,
              targetWeight: double.tryParse(entry.value.weight) ?? 0.0,
              targetReps: int.tryParse(entry.value.reps) ?? 0,
            );
          }).toList(),
        );
      }).toList(),
    );

    try {
      if (widget.initialRoutine != null) {
        await DatabaseService().updateRoutine(
          currentUserId,
          widget.initialRoutine!.id,
          newRoutine.toMap(),
        );
      } else {
        await DatabaseService().saveRoutine(currentUserId, newRoutine.toMap());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.initialRoutine != null
                  ? 'Routine Updated Successfully!'
                  : 'Routine Saved Successfully!',
              style: const TextStyle(color: Colors.greenAccent),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save routine: $e', style: const TextStyle(color: Colors.redAccent))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.initialRoutine != null;

    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: Colors.teal[900],
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _isLoadingInitialData
            ? const Center(
                child: CircularProgressIndicator(color: Colors.greenAccent),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      // Text field for the Routine Name
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.teal[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _routineNameController,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: 'Routine Name (e.g. Push Day)',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Render list of RoutineExerciseCard widgets from local state
                      ..._routineExercises.asMap().entries.map((entry) {
                        int exIndex = entry.key;
                        RoutineExerciseData routineEx = entry.value;

                        return RoutineExerciseCard(
                          exerciseIndex: exIndex,
                          routineExercise: routineEx,
                          onDeleteExercise: () {
                            setState(() {
                              _routineExercises.removeAt(exIndex);
                            });
                          },
                          onAddSet: () {
                            setState(() {
                              routineEx.sets.add(RoutineSetData());
                            });
                          },
                          onDeleteSet: (setIndex) {
                            setState(() {
                              routineEx.sets.removeAt(setIndex);
                            });
                          },
                          onSetChanged: (setIndex, weight, reps) {
                            routineEx.sets[setIndex].weight = weight;
                            routineEx.sets[setIndex].reps = reps;
                          },
                        );
                      }),

                      const SizedBox(height: 20),

                      // Add exercise button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[800],
                          foregroundColor: Colors.tealAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.add_rounded, color: Colors.tealAccent),
                        label: const Text(
                          'Add Exercise',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        onPressed: _navigateAndAddExercise,
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.teal[900],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isSubmitting ? null : _saveRoutine,
                          child: Text(
                            _isSubmitting
                                ? 'SAVING...'
                                : (isEditing ? 'UPDATE ROUTINE' : 'SAVE ROUTINE'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
