import 'dart:async';
import 'dart:math';
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
  // Pool of light bodyweight and stretching activities
  final List<String> _activityPool = const [
    '8 Sit-ups',
    '10 Jumping Jacks',
    '20-Second Plank',
    '10s Touching the Toes',
    '10 Arm Circles',
    '8 Shoulder Rolls',
    '15-Second Neck Stretch',
    '10 Standing Calf Raises',
    '10 Cobra Stretches',
    '10 Seated Torso Twists',
  ];

  Timer? _countdownTimer;
  bool _isClaiming = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // Calculates remaining time until 00:00:00 midnight
  String _getFormattedCountdown() {
    DateTime now = DateTime.now();
    DateTime midnight = DateTime(now.year, now.month, now.day + 1);
    Duration remaining = midnight.difference(now);

    String hours = remaining.inHours.toString().padLeft(2, '0');
    String minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  // Deterministically selects 5 light exercises for today based on date seed
  List<String> _getTodayQuests() {
    DateTime now = DateTime.now();
    int dateSeed = now.year * 10000 + now.month * 100 + now.day;
    List<String> pool = List.from(_activityPool)..shuffle(Random(dateSeed));
    return pool.take(5).toList();
  }

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

      // Roll randomized rewards on completion (1-12 XP, 1-8 Coins)
      int xpGained = Random().nextInt(12) + 1;
      int coinsGained = Random().nextInt(8) + 1;

      int updatedXp = currentXp + xpGained;
      int updatedLevel = currentLevel < 1 ? 1 : currentLevel;
      while (updatedXp >= 100) {
        updatedXp -= 100;
        updatedLevel += 1;
      }

      int updatedCoin = currentCoin + coinsGained;

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
          SnackBar(
            content: Text('Side Quest Complete! +$xpGained XP & +$coinsGained Coins', style: const TextStyle(color: AppColors.warmIvory)),
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
    List<String> todayQuests = _getTodayQuests();

    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                'Daily Side Quests',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.warmIvory,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: Text(
                'Quests Reset In: ${_getFormattedCountdown()}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayQuests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                String questText = todayQuests[index];
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