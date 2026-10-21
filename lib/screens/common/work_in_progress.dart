import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Placeholder screen for features that are not built yet.
class WorkInProgress extends StatelessWidget {
  final String title;
  const WorkInProgress({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidianBlack,
      appBar: AppBar(
        title: Text(title),
        iconTheme: const IconThemeData(color: AppColors.warmIvory),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction, size: 80, color: AppColors.questGold),
              const SizedBox(height: 24),
              const Text(
                'Work in progress',
                style: TextStyle(
                  color: AppColors.warmIvory,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The $title page is still being forged.\nCheck back soon, Slayer!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.parchmentBeige, fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
