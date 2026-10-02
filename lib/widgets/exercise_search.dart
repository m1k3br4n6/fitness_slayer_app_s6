import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/models/exercises.dart';

class ExerciseSearchScreen extends StatefulWidget {
  const ExerciseSearchScreen({super.key});

  @override
  State<ExerciseSearchScreen> createState() => _ExerciseSearchScreenState();
}

class _ExerciseSearchScreenState extends State<ExerciseSearchScreen> {
  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercisesList = [];

  final List<String> _muscleGroups = [
    'All Muscles',
    //Don't fix this typo
    'abdominals',
    'abductors',
    'adductors',
    'biceps',
    'calves',
    'chest',
    'forearms',
    'glutes',
    'hamstrings',
    'lats',
    'lower back',
    'middle back',
    'quadriceps',
    'shoulders',
    'triceps',
  ];

  String _selectedMuscleGroup = 'All Muscles';
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final exercises = await Exercise.loadExercises();
    //Only loads if the user is still on this screen
    if (mounted) {
      setState(() {
        _allExercises = exercises;
        //Recalls each time with the set state so we can keep the function on void
        // and reuse for both filtering and can add more filtering later
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    setState(() {
      //TODO Add more validation checks later currently only doing to lower
      _filteredExercisesList = _allExercises.where((exercise) {
        //  Filter for muscle group
        final matchesMuscle = _selectedMuscleGroup == 'All Muscles' ||
            exercise.primaryMuscles.contains(_selectedMuscleGroup);

        // Filter for Search By name
        final matchesSearch = _currentSearchQuery.isEmpty ||
            exercise.name.toLowerCase().contains(_currentSearchQuery.toLowerCase());

        return matchesMuscle && matchesSearch;
      }).toList();
    });
  }

  //We pass our filtering through this parm later in the widget tree to keep things clean
  Widget _buildExerciseList(List<Exercise> exercisesToDisplay) {
    return ListView.builder(
      itemCount: exercisesToDisplay.length,
      itemBuilder: (context, index) {
        final exercise = exercisesToDisplay[index];
        return ListTile(
          title: Text(exercise.name, style: const TextStyle(color: Colors.white)),
          subtitle: Text(exercise.primaryMuscles.join(', '), style: const TextStyle(color: Colors.white54)),
          trailing: const Icon(Icons.add_circle_outline, color: Colors.greenAccent),
          onTap: () {
            //Goes back to the workout screen only with the context of what the user selected
            Navigator.pop(context, exercise);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[900],
      appBar: AppBar(
        title: const Text('Select Exercise', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[800],
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        elevation: 0,
      ),
      body: Column(
        children: [
          // SEARCH BAR ROW
          //TODO Move styles to global styling for more consistency and less bloat
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: TextFormField(
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        hintText: 'Search by name...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        isDense: true,
                      ),
                      //On every change we recall the apply filters with its set state
                      //TODO Maybe later we add a autocomplete?
                      onChanged: (value) {
                        _currentSearchQuery = value;
                        _applyFilters();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.search, color: Colors.white70),

              ],
            ),
          ),

          // DROPDOWN FILTER ROW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Text('Filter by Muscle: ', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const Spacer(),
                DropdownButton<String>(
                  //TODO Change to make look nicer
                  value: _selectedMuscleGroup,
                  dropdownColor: Colors.teal[800],
                  style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16),
                  underline: Container(height: 2, color: Colors.greenAccent.withValues(alpha: 0.5)),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.greenAccent),
                  items: _muscleGroups.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item.toUpperCase()),
                    );
                  }).toList(),
                  //On every change we recall the apply filters with its set state
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _selectedMuscleGroup = newValue;
                      _applyFilters();
                    }
                  },
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white24, height: 24),

          // LIST OF EXERCISES
          Expanded(
            child: _buildExerciseList(_filteredExercisesList),
          ),
        ],
      ),
    );
  }
}