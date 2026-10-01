import 'dart:convert';
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

  Exercise({
    required this.id,
    required this.name,
    required this.equipment,
    required this.primaryMuscles,
    required this.category,
    required this.mechanic,
    required this.force,
    required this.instructions
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      equipment: json['equipment'] ?? 'body only',
      primaryMuscles: List<String>.from(json['primaryMuscles'] ?? []),
      category: json['category'] ?? 'strength',
      mechanic: json['mechanic'] ?? 'compound',
      force: json['force'] ?? 'pull',
      instructions: List<String>.from(json['instructions'] ?? []),

    );
  }

  static Future<List<Exercise>> loadExercises() async {
    final String response = await rootBundle.loadString('assets/exercises.json');
    final List<dynamic> data = json.decode(response);

    return data.map((json) => Exercise.fromJson(json)).toList();
  }
}