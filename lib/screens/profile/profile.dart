import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/screens/profile/badges.dart';
import 'package:fitness_slayer_01/screens/profile/fitness_stats.dart';
import 'package:fitness_slayer_01/screens/social/friends.dart';
import 'package:fitness_slayer_01/widgets/loading.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

int _xpForNextLevel(int level) => (level < 1 ? 1 : level) * 100;

int _intField(Map<String, dynamic> data, String key) => (data[key] as num?)?.toInt() ?? 0;

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final userDoc = Provider.of<DocumentSnapshot?>(context);
    final user = Provider.of<myUser?>(context);

    if (userDoc == null || user == null) {
      return Scaffold(backgroundColor: AppColors.obsidianBlack, body: Loading());
    }

    final data = userDoc.exists
        ? (userDoc.data() as Map<String, dynamic>? ?? <String, dynamic>{})
        : <String, dynamic>{};
    final username = (data['username'] as String?) ?? 'Slayer';
    final level = _intField(data, 'level');
    final xp = _intField(data, 'xp');
    final coins = _intField(data, 'coin');
    final streak = _intField(data, 'streak');

    final xpNeeded = _xpForNextLevel(level);
    final xpProgress = (xp / xpNeeded).clamp(0.0, 1.0).toDouble();
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.obsidianBlack,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Avatar, name and level
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.questGold, width: 2),
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.forgeSlate,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.warmIvory,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              username,
              style: const TextStyle(
                color: AppColors.warmIvory,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Level $level Slayer',
              style: const TextStyle(color: AppColors.questGold, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // XP progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.forgeSlate,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.hearthBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Experience',
                        style: TextStyle(color: AppColors.warmIvory, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '$xp / $xpNeeded XP',
                        style: const TextStyle(color: AppColors.parchmentBeige),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: xpProgress,
                      minHeight: 12,
                      backgroundColor: AppColors.hearthStone,
                      color: AppColors.emberOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick stats
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.local_fire_department,
                    color: AppColors.emberOrange,
                    value: '$streak',
                    label: 'Day streak',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    icon: Icons.monetization_on,
                    color: AppColors.questGold,
                    value: '$coins',
                    label: 'Coins',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _WorkoutCountTile(uid: user.uid)),
              ],
            ),
            const SizedBox(height: 16),

            // Links to the other profile screens
            _ShortcutTile(
              icon: Icons.insights,
              label: 'Fitness Stats',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FitnessStats()),
              ),
            ),
            const SizedBox(height: 12),
            _ShortcutTile(
              icon: Icons.emoji_events,
              label: 'Badges',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Badges()),
              ),
            ),
            const SizedBox(height: 12),
            _ShortcutTile(
              icon: Icons.people,
              label: 'Friends',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Friends()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.forgeSlate,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hearthBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.warmIvory,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: const TextStyle(color: AppColors.parchmentBeige, fontSize: 12)),
        ],
      ),
    );
  }
}

class _WorkoutCountTile extends StatefulWidget {
  final String uid;
  const _WorkoutCountTile({required this.uid});

  @override
  State<_WorkoutCountTile> createState() => _WorkoutCountTileState();
}

class _WorkoutCountTileState extends State<_WorkoutCountTile> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _workouts;

  Stream<QuerySnapshot<Map<String, dynamic>>> _openStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('workoutsCompleted')
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    _workouts = _openStream();
  }

  @override
  void didUpdateWidget(covariant _WorkoutCountTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      _workouts = _openStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _workouts,
      builder: (context, snapshot) {
        final count = snapshot.hasData ? '${snapshot.data!.docs.length}' : '-';
        return _StatTile(
          icon: Icons.fitness_center,
          color: AppColors.questGold,
          value: count,
          label: 'Workouts',
        );
      },
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShortcutTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.forgeSlate,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon, color: AppColors.emberOrange),
        title: Text(label, style: const TextStyle(color: AppColors.warmIvory)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.parchmentBeige),
        onTap: onTap,
      ),
    );
  }
}