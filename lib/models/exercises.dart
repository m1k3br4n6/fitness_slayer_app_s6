import 'dart:convert';
import 'package:flutter/services.dart';

class Exercise {
  final String id;
  final String name;
  final String bodyPart;

  Exercise({
    required this.id,
    required this.name,
    required this.bodyPart
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['slug'] ?? '',
      name: json['name_en'] ?? 'Unknown',
      bodyPart: json['category'] ?? 'General',
    );
  }

  // Parses the RepDB exercises.json file
  static Future<List<Exercise>> loadExercises() async {
    final String response = await rootBundle.loadString('assets/exercise-list.json');
    final data = json.decode(response);

    // RepDB nests the array under exercises key
    final List<dynamic> exercisesJson = data['exercises'];
    return exercisesJson.map((json) => Exercise.fromJson(json)).toList();
  }
}