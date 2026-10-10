import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/models/exercises.dart';

class ExerciseSearchScreen extends StatefulWidget {
  const ExerciseSearchScreen({super.key});

  @override
  State<ExerciseSearchScreen> createState() => _ExerciseSearchScreenState();
}

class _ExerciseSearchScreenState extends State<ExerciseSearchScreen> {
  // Controller for managing search input text and allowing 1-press clear ('X')
  final TextEditingController _searchController = TextEditingController();

  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercisesList = [];

  final List<String> _muscleGroups = [
    'All Muscles',
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

  @override
  void dispose() {
    // Dispose controller when screen is closed to prevent memory leaks
    _searchController.dispose();
    super.dispose();
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

  // Converts raw muscle group strings, "lower back", to Title Case, "Lower Back"
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
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
          // Desaturated trailing icon color
          trailing: Icon(Icons.add_circle_outline, color: Colors.teal[200]),
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
        // Softened back arrow icon color
        iconTheme: IconThemeData(color: Colors.teal[200]),
        elevation: 0,
      ),
      body: Column(
        children: [
          // SEARCH BAR ROW
          //TODO Move styles to global styling for more consistency and less bloat
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal[800],
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: TextFormField(
                controller: _searchController,
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  isDense: true,
                  // As per the controller above I just wanted to add a clear button for a one press clear when users are searching
                  suffixIcon: _currentSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70, size: 20),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _currentSearchQuery = '';
                              _applyFilters();
                            });
                          },
                        )
                      : const Icon(Icons.search, color: Colors.white54, size: 20),
                ),
                //On every change we recall the apply filters with its set state
                // NOTE: Real-time list filtering used instead of autocomplete overlay.
                onChanged: (value) {
                  setState(() {
                    _currentSearchQuery = value;
                    _applyFilters();
                  });
                },
              ),
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
                //Using pill-style container matching the search bar rounded aesthetic
                // Muted border color for less visual saturation
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal[800],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  // DropdownButtonHideUnderline removes legacy underline decoration (basically we end up with a cleaner, pill container look)
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMuscleGroup,
                      dropdownColor: Colors.teal[800],
                      borderRadius: BorderRadius.circular(12),
                      // Softened text and arrow icon color
                      style: TextStyle(color: Colors.teal[200], fontWeight: FontWeight.bold, fontSize: 15),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.teal[200]),
                      isDense: true,
                      items: _muscleGroups.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          // Uses _capitalize to format to Title Case as mentioned above
                          child: Text(_capitalize(item)),
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
                  ),
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