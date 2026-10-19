import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';

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
          style: const TextStyle(color: AppColors.parchmentWhite, fontSize: 18),
        ),
        backgroundColor: AppColors.hearthPanel,
        iconTheme: const IconThemeData(color: AppColors.gemGold),
        elevation: 0,
      ),
      backgroundColor: AppColors.slateBackdrop,
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
        color: AppColors.hearthPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.woodFrame, width: 1),
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
                    color: AppColors.woodFrame,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    stepLabel,
                    style: const TextStyle(
                      color: AppColors.gemGold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.parchmentWhite,
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
                  color: AppColors.slateBackdrop,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.flameOrange),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: AppColors.slateBackdrop,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image_outlined, color: AppColors.brassBorder, size: 48),
                      SizedBox(height: 8),
                      Text(
                        'Image not available',
                        style: TextStyle(color: AppColors.brassBorder, fontSize: 14),
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
