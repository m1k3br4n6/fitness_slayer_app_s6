import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/services/streak_service.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const int _dailyQuestCount = 5;
const int _xpPerLevel = 100;

class _Quest {
  final String text;
  final int index;
  const _Quest(this.text, this.index);
}

class SideQuest extends StatefulWidget {
  const SideQuest({super.key});

  @override
  State<SideQuest> createState() => _SideQuestState();
}

class _SideQuestState extends State<SideQuest> {
  // Pool of low effort stretches and exercises that daily quests are drawn from
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

  bool _isClaiming = false;

  // Single source of truth for completion keys, used when saving and when reading
  String _dayPrefix(DateTime date) => '${date.year}-${date.month}-${date.day}_';
  String _questKey(DateTime date, int index) => '${_dayPrefix(date)}$index';

  // The same date always gives the same shuffle, so the quest list is stable all day
  List<_Quest> _getTodayQuests() {
    final now = DateTime.now();
    final dateSeed = now.year * 10000 + now.month * 100 + now.day;
    final pool = List<String>.from(_activityPool)..shuffle(Random(dateSeed));
    final picked = pool.take(_dailyQuestCount).toList();
    return [for (int i = 0; i < picked.length; i++) _Quest(picked[i], i)];
  }

  void _showFloatingLoot(Offset buttonCenter, int xpGained, int coinsGained) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return _FloatingLootOverlay(
          buttonCenter: buttonCenter,
          xpGained: xpGained,
          coinsGained: coinsGained,
          onDismiss: () {
            if (overlayEntry.mounted) {
              overlayEntry.remove();
            }
          },
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);
  }

  Future<void> _completeQuest(
      String uid,
      int questIndex, {
        Offset? buttonCenter,
      }) async {
    if (_isClaiming) return;

    SystemSound.play(SystemSoundType.click);
    setState(() => _isClaiming = true);

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final now = DateTime.now();
      final questKey = _questKey(now, questIndex);
      final questText = _getTodayQuests()[questIndex].text;

      // Rolled outside the transaction so a retry does not re-roll the reward
      final xpGained = Random().nextInt(12) + 1;
      final coinsGained = Random().nextInt(8) + 1;

      // Transaction: re-reads the latest user document before writing, so a stale
      // snapshot or a double tap cannot overwrite XP or award a quest twice
      final awarded = await FirebaseFirestore.instance.runTransaction<bool>((transaction) async {
        final snapshot = await transaction.get(userRef);
        final data = snapshot.data() ?? <String, dynamic>{};

        // Keep only today's keys so old days do not pile up in the document
        final completedQuests = List<String>.from(data['completedSideQuests'] ?? [])
            .where((key) => key.startsWith(_dayPrefix(now)))
            .toList();
        if (completedQuests.contains(questKey)) return false;
        completedQuests.add(questKey);

        final currentXp = (data['xp'] as num?)?.toInt() ?? 0;
        final currentLevel = (data['level'] as num?)?.toInt() ?? 1;
        final currentCoin = (data['coin'] as num?)?.toInt() ?? 0;
        final currentStreak = (data['streak'] as num?)?.toInt() ?? 0;

        DateTime? lastWorkoutDate;
        final rawLastDate = data['lastWorkoutDate'];
        if (rawLastDate is Timestamp) {
          lastWorkoutDate = rawLastDate.toDate();
        } else if (rawLastDate is DateTime) {
          lastWorkoutDate = rawLastDate;
        }

        var updatedXp = currentXp + xpGained;
        var updatedLevel = currentLevel < 1 ? 1 : currentLevel;
        while (updatedXp >= _xpPerLevel) {
          updatedXp -= _xpPerLevel;
          updatedLevel += 1;
        }

        final updatedStreak = StreakService.calculateNewStreak(
          currentStreak: currentStreak,
          lastWorkoutDate: lastWorkoutDate,
          currentWorkoutDate: now,
        );

        transaction.set(userRef, {
          'xp': updatedXp,
          'level': updatedLevel,
          'coin': currentCoin + coinsGained,
          'streak': updatedStreak,
          'lastWorkoutDate': now,
          'completedSideQuests': completedQuests,
        }, SetOptions(merge: true));

        // Permanent history for the calendar. The document id is the quest key,
        // so each quest can only be logged once per day
        transaction.set(
          userRef.collection('sideQuestLog').doc(questKey),
          {
            'text': questText,
            'xp': xpGained,
            'coins': coinsGained,
            'dateCompleted': Timestamp.fromDate(now),
          },
        );

        return true;
      });

      if (awarded && mounted) {
        _showFloatingLoot(buttonCenter ?? const Offset(200, 300), xpGained, coinsGained);
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
        setState(() => _isClaiming = false);
      }
    }
  }

  Widget _buildQuestCard({
    required _Quest quest,
    required bool isDone,
    required String uid,
  }) {
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
            isDone ? Icons.check_circle : Icons.priority_high,
            color: isDone ? AppColors.gold : AppColors.primary,
            size: 26,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              quest.text,
              style: TextStyle(
                color: isDone ? AppColors.parchmentBeige : AppColors.warmIvory,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          // Builder gives the button its own context, so its position can be
          // read without a GlobalKey that gets recreated on every rebuild
          Builder(
            builder: (btnContext) => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone ? AppColors.container : AppColors.primary,
                foregroundColor: AppColors.warmIvory,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: isDone
                  ? null
                  : () {
                Offset? buttonCenter;
                final renderBox = btnContext.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  buttonCenter = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
                }
                _completeQuest(uid, quest.index, buttonCenter: buttonCenter);
              },
              child: Text(
                isDone ? 'Completed' : 'Complete',
                style: TextStyle(
                  color: isDone ? AppColors.textMuted : AppColors.warmIvory,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

    final Map<String, dynamic> userData =
    userDoc.exists ? (userDoc.data() as Map<String, dynamic>? ?? <String, dynamic>{}) : <String, dynamic>{};
    final now = DateTime.now();
    final completedQuests = List<String>.from(userData['completedSideQuests'] ?? []);

    final activeQuests = <_Quest>[];
    final finishedQuests = <_Quest>[];

    for (final quest in _getTodayQuests()) {
      if (completedQuests.contains(_questKey(now, quest.index))) {
        finishedQuests.add(quest);
      } else {
        activeQuests.add(quest);
      }
    }

    final completedCount = finishedQuests.length;
    final allCleared = completedCount == _dailyQuestCount;

    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: double.infinity,
              child: Text(
                'Slayer Quest Board',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.warmIvory,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Progress card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: allCleared ? AppColors.gold : AppColors.border, width: 1.5),
              ),
              child: Column(
                children: [
                  if (allCleared) ...[
                    const Text(
                      'Notice Board Cleared!',
                      style: TextStyle(color: AppColors.warmIvory, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    allCleared
                        ? 'All $_dailyQuestCount daily quests completed for today. Come back tomorrow for more quests!'
                        : '$completedCount / $_dailyQuestCount Quests Completed Today',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.parchmentBeige, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: completedCount / _dailyQuestCount,
                      minHeight: 8,
                      backgroundColor: AppColors.container,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _CountdownLabel(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (activeQuests.isNotEmpty) ...[
              const Text(
                'Active Quests',
                style: TextStyle(color: AppColors.warmIvory, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...activeQuests.map((quest) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildQuestCard(quest: quest, isDone: false, uid: user.uid),
                );
              }),
            ],

            if (finishedQuests.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              const SizedBox(height: 12),
              Text(
                'Completed Today ($completedCount / $_dailyQuestCount)',
                style: const TextStyle(color: AppColors.parchmentBeige, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...finishedQuests.map((quest) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildQuestCard(quest: quest, isDone: true, uid: user.uid),
                );
              }),
            ],

            const SizedBox(height: 24),

            /*
             Testing reset button, disabled.
             Note: the flat 5 XP / 3 coin refund
             does not match the random 1-12 XP / 1-8 coin rewards, so the real
             amounts would need to be stored per quest before re-enabling this.
            */
            /*
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.refresh, color: AppColors.crimsonRed, size: 18),
                label: const Text('Reset Quests & XP/Coins (Testing)', style: TextStyle(color: AppColors.crimsonRed, fontSize: 13)),
                onPressed: () async {
                  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

                  int currentXp = (userData['xp'] as num?)?.toInt() ?? 0;
                  int currentCoin = (userData['coin'] as num?)?.toInt() ?? 0;

                  int xpToDeduct = finishedQuests.length * 5;
                  int coinsToDeduct = finishedQuests.length * 3;

                  int newXp = (currentXp - xpToDeduct).clamp(0, 999999);
                  int newCoin = (currentCoin - coinsToDeduct).clamp(0, 999999);

                  await userRef.set({
                    'completedSideQuests': [],
                    'xp': newXp,
                    'coin': newCoin,
                  }, SetOptions(merge: true));

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Quests reset to 0/$_dailyQuestCount (-$xpToDeduct XP, -$coinsToDeduct Coins)')),
                    );
                  }
                },
              ),
            ),
            */
          ],
        ),
      ),
    );
  }
}

// Owns its own timer so only this label rebuilds each second, not the whole screen
class _CountdownLabel extends StatefulWidget {
  const _CountdownLabel();

  @override
  State<_CountdownLabel> createState() => _CountdownLabelState();
}

class _CountdownLabelState extends State<_CountdownLabel> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Time remaining until local midnight
  String _formatRemaining() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final remaining = midnight.difference(now);

    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Next Quests In: ${_formatRemaining()}',
      style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold),
    );
  }
}

// Floating "+X XP" and "+Y GP" bubbles that rise and fade over the pressed button
class _FloatingLootOverlay extends StatefulWidget {
  final Offset buttonCenter;
  final int xpGained;
  final int coinsGained;
  final VoidCallback onDismiss;

  const _FloatingLootOverlay({
    required this.buttonCenter,
    required this.xpGained,
    required this.coinsGained,
    required this.onDismiss,
  });

  @override
  State<_FloatingLootOverlay> createState() => _FloatingLootOverlayState();
}

class _FloatingLootOverlayState extends State<_FloatingLootOverlay> with SingleTickerProviderStateMixin {
  static const double _bubbleSize = 52;
  static const double _bubbleGap = 8;
  static const double _totalWidth = _bubbleSize * 2 + _bubbleGap;

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _translateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Fully opaque for most of the animation, fading only near the end
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.65, 1.0, curve: Curves.easeOut)),
    );

    _translateAnimation = Tween<double>(begin: 0.0, end: -60.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Centers the pair of bubbles on the button while keeping them on screen
    final screenWidth = MediaQuery.of(context).size.width;
    final leftPosition = (widget.buttonCenter.dx - _totalWidth / 2).clamp(12.0, screenWidth - _totalWidth - 12.0);

    return Positioned(
      left: leftPosition,
      top: widget.buttonCenter.dy - 45,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _translateAnimation.value),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LootBubble(label: '+${widget.xpGained}XP', color: AppColors.primary),
                  const SizedBox(width: _bubbleGap),
                  _LootBubble(label: '+${widget.coinsGained}GP', color: AppColors.gold),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LootBubble extends StatelessWidget {
  final String label;
  final Color color;

  const _LootBubble({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _FloatingLootOverlayState._bubbleSize,
      height: _FloatingLootOverlayState._bubbleSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          height: 1.1,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}