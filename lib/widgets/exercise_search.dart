import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/models/exercises.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';

class ExerciseSearchScreen extends StatefulWidget {
  const ExerciseSearchScreen({super.key});

  @override
  State<ExerciseSearchScreen> createState() => _ExerciseSearchScreenState();
}

class _ExerciseSearchScreenState extends State<ExerciseSearchScreen> {
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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final exercises = await Exercise.loadExercises();
    if (mounted) {
      setState(() {
        _allExercises = exercises;
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredExercisesList = _allExercises.where((exercise) {
        final matchesMuscle = _selectedMuscleGroup == 'All Muscles' ||
            exercise.primaryMuscles.contains(_selectedMuscleGroup);

        final matchesSearch = _currentSearchQuery.isEmpty ||
            exercise.name.toLowerCase().contains(_currentSearchQuery.toLowerCase());

        return matchesMuscle && matchesSearch;
      }).toList();
    });
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }

  Widget _buildExerciseList(List<Exercise> exercisesToDisplay) {
    return ListView.builder(
      itemCount: exercisesToDisplay.length,
      itemBuilder: (context, index) {
        final exercise = exercisesToDisplay[index];
        return ListTile(
          title: Text(exercise.name, style: const TextStyle(color: AppColors.parchmentWhite)),
          subtitle: Text(exercise.primaryMuscles.join(', '), style: const TextStyle(color: AppColors.brassBorder)),
          trailing: const Icon(Icons.add_circle_outline, color: AppColors.gemGold),
          onTap: () {
            Navigator.pop(context, exercise);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slateBackdrop,
      appBar: AppBar(
        title: const Text('Select Exercise', style: TextStyle(color: AppColors.parchmentWhite)),
        backgroundColor: AppColors.hearthPanel,
        iconTheme: const IconThemeData(color: AppColors.gemGold),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.hearthPanel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.woodFrame, width: 1),
              ),
              alignment: Alignment.center,
              child: TextFormField(
                controller: _searchController,
                textAlign: TextAlign.left,
                style: const TextStyle(color: AppColors.parchmentWhite, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  hintStyle: const TextStyle(color: AppColors.brassBorder),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  isDense: true,
                  suffixIcon: _currentSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.parchmentWhite, size: 20),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _currentSearchQuery = '';
                              _applyFilters();
                            });
                          },
                        )
                      : const Icon(Icons.search, color: AppColors.brassBorder, size: 20),
                ),
                onChanged: (value) {
                  setState(() {
                    _currentSearchQuery = value;
                    _applyFilters();
                  });
                },
              ),
            ),
          ),

          // Dropdown filter row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Text('Filter by Muscle: ', style: TextStyle(color: AppColors.parchmentWhite, fontSize: 16)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.hearthPanel,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.woodFrame),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMuscleGroup,
                      dropdownColor: AppColors.hearthPanel,
                      borderRadius: BorderRadius.circular(12),
                      style: const TextStyle(color: AppColors.gemGold, fontWeight: FontWeight.bold, fontSize: 15),
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.gemGold),
                      isDense: true,
                      items: _muscleGroups.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(_capitalize(item)),
                        );
                      }).toList(),
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

          const Divider(color: AppColors.woodFrame, height: 24),

          // List of exercises
          Expanded(
            child: _buildExerciseList(_filteredExercisesList),
          ),
        ],
      ),
    );
  }
}
