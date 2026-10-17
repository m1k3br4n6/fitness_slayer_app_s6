import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Exercise {
  final String id;
  final String name;
  final String equipment;
  final List<String> primaryMuscles;
  final String category;
  final String mechanic;
  final String force;
  final List<String> instructions;

  // Static in-memory cache so exercises.json is loaded and parsed ONLY ONCE
  static List<Exercise>? _cachedExercises;

  Exercise({
    required this.id,
    required this.name,
    required this.equipment,
    required this.primaryMuscles,
    required this.category,
    required this.mechanic,
    required this.force,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      equipment: (json['equipment'] == null || json['equipment'].toString().trim().isEmpty)
          ? 'N/A'
          : json['equipment'].toString().trim(),
      primaryMuscles: List<String>.from(json['primaryMuscles'] ?? []),
      category: (json['category'] == null || json['category'].toString().trim().isEmpty)
          ? 'N/A'
          : json['category'].toString().trim(),
      mechanic: (json['mechanic'] == null || json['mechanic'].toString().trim().isEmpty)
          ? 'N/A'
          : json['mechanic'].toString().trim(),
      force: (json['force'] == null || json['force'].toString().trim().isEmpty)
          ? 'N/A'
          : json['force'].toString().trim(),
      instructions: List<String>.from(json['instructions'] ?? []),
    );
  }

  // Top-level / static function for compute isolate parsing
  static List<Exercise> _parseExercisesJson(String jsonString) {
    final List<dynamic> data = json.decode(jsonString);
    return data.map((json) => Exercise.fromJson(json)).toList();
  }

  static Future<List<Exercise>> loadExercises() async {
    // 1. If already loaded in memory, return cached list instantly (0ms)
    if (_cachedExercises != null) {
      return _cachedExercises!;
    }

    // 2. Read asset file string
    final String response = await rootBundle.loadString('assets/exercises.json');

    // 3. Use compute() to parse 22,000+ lines in a background isolate off the UI main thread
    _cachedExercises = await compute(_parseExercisesJson, response);

    return _cachedExercises!;
  }
}
