import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/services/streak_service.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SideQuest extends StatefulWidget {
  const SideQuest({super.key});

  @override
  State<SideQuest> createState() => _SideQuestState();
}

class _SideQuestState extends State<SideQuest> {
  final List<String> _dailyQuests = const [
    '8 Sit-ups',
    '4 Bodyweight Squats',
    '10 Jumping Jacks',
    '20-Second Plank',
    '10s Touching the toes',
  ];

  bool _isClaiming = false;

  Future<void> _completeQuest(
    String uid,
    int questIndex,
    Map<dynamic, dynamic> userData,
  ) async {
    if (_isClaiming) return;

    setState(() {
      _isClaiming = true;
    });

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

      int currentXp = (userData['xp'] as num?)?.toInt() ?? 0;
      int currentLevel = (userData['level'] as num?)?.toInt() ?? 1;
      int currentCoin = (userData['coin'] as num?)?.toInt() ?? 0;
      int currentStreak = (userData['streak'] as num?)?.toInt() ?? 0;

      DateTime? lastWorkoutDate;
      final rawLastDate = userData['lastWorkoutDate'];
      if (rawLastDate is Timestamp) {
        lastWorkoutDate = rawLastDate.toDate();
      } else if (rawLastDate is DateTime) {
        lastWorkoutDate = rawLastDate;
      }

      int updatedXp = currentXp + 5;
      int updatedLevel = currentLevel < 1 ? 1 : currentLevel;
      while (updatedXp >= 100) {
        updatedXp -= 100;
        updatedLevel += 1;
      }

      int updatedCoin = currentCoin + 3;

      DateTime now = DateTime.now();
      int updatedStreak = StreakService.calculateNewStreak(
        currentStreak: currentStreak,
        lastWorkoutDate: lastWorkoutDate,
        currentWorkoutDate: now,
      );

      List<String> completedQuests = List<String>.from(userData['completedSideQuests'] ?? []);
      String questKey = '${now.year}-${now.month}-${now.day}_$questIndex';
      if (!completedQuests.contains(questKey)) {
        completedQuests.add(questKey);
      }

      await userRef.set({
        'xp': updatedXp,
        'level': updatedLevel,
        'coin': updatedCoin,
        'streak': updatedStreak,
        'lastWorkoutDate': now,
        'completedSideQuests': completedQuests,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Side Quest Complete!', style: TextStyle(color: AppColors.warmIvory)),
            backgroundColor: AppColors.surface,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete quest: $e', style: const TextStyle(color: AppColors.crimsonWine)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isClaiming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDoc = Provider.of<DocumentSnapshot?>(context);
    final user = Provider.of<myUser?>(context);

    if (userDoc == null || user == null) {
      return Scaffold(
        appBar: const MyAppBar(),
        backgroundColor: AppColors.background,
        body: const Loading(),
      );
    }

    final userData = userDoc.exists ? (userDoc.data() as Map<String, dynamic>? ?? {}) : {};
    DateTime now = DateTime.now();
    List<String> completedQuests = List<String>.from(userData['completedSideQuests'] ?? []);

    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Side Quests',
              style: TextStyle(
                color: AppColors.warmIvory,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Complete simple daily exercises for +5 XP & +3 Coins each.',
              style: TextStyle(color: AppColors.parchmentBeige, fontSize: 14),
            ),
            const SizedBox(height: 24),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dailyQuests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                String questText = _dailyQuests[index];
                String questKey = '${now.year}-${now.month}-${now.day}_$index';
                bool isDone = completedQuests.contains(questKey);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDone ? AppColors.gold : AppColors.border,
                      width: isDone ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDone ? Icons.check_circle : Icons.fitness_center,
                        color: isDone ? AppColors.gold : AppColors.primary,
                        size: 26,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              questText,
                              style: TextStyle(
                                color: isDone ? AppColors.parchmentBeige : AppColors.warmIvory,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '+5 XP  •  +3 Coins',
                              style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDone ? AppColors.container : AppColors.primary,
                          foregroundColor: AppColors.warmIvory,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: isDone ? null : () => _completeQuest(user.uid, index, userData),
                        child: Text(
                          isDone ? 'Completed' : 'Complete',
                          style: TextStyle(
                            color: isDone ? AppColors.textMuted : AppColors.warmIvory,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}