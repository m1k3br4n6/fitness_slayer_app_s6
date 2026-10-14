import 'package:flutter/material.dart';

class ExerciseDemoScreen extends StatelessWidget {
  final String exerciseId;
  final String exerciseName;

  const ExerciseDemoScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$exerciseName - Demo',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.teal[800],
        iconTheme: IconThemeData(color: Colors.teal[200]),
        elevation: 0,
      ),
      backgroundColor: Colors.teal[900],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildDemoCard(
              context,
              stepLabel: 'STEP 1',
              title: 'Starting Position',
              imageUrl: 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/$exerciseId/0.jpg',
            ),

            const SizedBox(height: 20),

            _buildDemoCard(
              context,
              stepLabel: 'STEP 2',
              title: 'Execution & Finish',
              imageUrl: 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/$exerciseId/1.jpg',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard(
    BuildContext context, {
    required String stepLabel,
    required String title,
    required String imageUrl,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.teal[800],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal[900],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    stepLabel,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 220,
                  color: Colors.teal[900],
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.greenAccent),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.teal[900],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image_outlined, color: Colors.white38, size: 48),
                      SizedBox(height: 8),
                      Text(
                        'Image not available',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
