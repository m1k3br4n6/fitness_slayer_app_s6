import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_slayer_01/models/completed_workout.dart';
import 'package:fitness_slayer_01/models/equipment.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/screens/common/work_in_progress.dart';
import 'package:fitness_slayer_01/screens/game-features/slayer_customize.dart';
import 'package:fitness_slayer_01/services/database_service.dart';
import 'package:fitness_slayer_01/services/sprite_animator.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:fitness_slayer_01/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';

// Returns the xp needed for the next level
int _xpForNextLevel(int level) => 100;

// Open the placeholder page
void _openWip(BuildContext context, String title) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => WorkInProgress(title: title),
    ),
  );
}

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user doc and auth user from provider
    final userDoc = Provider.of<DocumentSnapshot?>(context);
    final user = Provider.of<myUser?>(context);

    // Show loading screen until user info is available
    if (userDoc == null || user == null) {
      return const Scaffold(
        backgroundColor: AppColors.obsidianBlack,
        body: Loading(),
      );
    }

    // Extract user data
    final data = userDoc.data() as Map<String, dynamic>? ?? {};
    final username = data['username'] as String? ?? 'Slayer';
    final level = (data['level'] as num?)?.toInt() ?? 0;
    final xp = (data['xp'] as num?)?.toInt() ?? 0;
    final coins = (data['coin'] as num?)?.toInt() ?? 0;
    final streak = (data['streak'] as num?)?.toInt() ?? 0;
    final photoBase64 = data['photoBase64'] as String?;

    // Calculate progress bar value
    final xpNeeded = _xpForNextLevel(level);
    final xpRatio = (xp / xpNeeded).clamp(0.0, 1.0).toDouble();
    final xpFrame = (xpRatio * 7).round().clamp(0, 7);

    // Uses username's first letter if no profile photo is available
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.obsidianBlack,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Avatar, username and level
            _ProfileAvatar(
              uid: user.uid,
              initial: initial,
              photoBase64: photoBase64,
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
              style: const TextStyle(
                color: AppColors.questGold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // XP progress towards the next level
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.forgeSlate,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.hearthBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Experience',
                        style: TextStyle(
                          color: AppColors.warmIvory,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$xp / $xpNeeded XP',
                        style: const TextStyle(color: AppColors.parchmentBeige),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      alignment: Alignment.centerLeft,
                      child: SpriteAnimator.play(
                        'bars/xp_bar_Sheet',
                        scale: 0.5,
                        frameCount: 8,
                        staticFrame: xpFrame,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Display user streak, coins and completed workouts
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
                Expanded(
                  child: _WorkoutCountTile(uid: user.uid),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Slayer summary and customize button
            StreamBuilder<Map<String, dynamic>?>(
              stream: DatabaseService().getSlayerDataStream(user.uid),
              builder: (context, slayerSnapshot) {
                final slayerData = slayerSnapshot.data ?? {};
                final slayerName = (slayerData['slayer_name'] as String?)?.trim() ?? '';
                final displayedName = slayerName.isEmpty ? 'Your Slayer' : slayerName;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.forgeSlate,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.hearthBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayedName,
                        style: const TextStyle(
                          color: AppColors.warmIvory,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _EquippedOutfitName(uid: user.uid),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SlayerCustomize()),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Customize Slayer'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Shortcuts
            _ShortcutTile(
              icon: Icons.insights,
              label: 'Fitness Stats',
              onTap: () => _openWip(context, 'Fitness Stats'),
            ),
            const SizedBox(height: 12),
            _ShortcutTile(
              icon: Icons.emoji_events,
              label: 'Badges',
              onTap: () => _openWip(context, 'Badges'),
            ),
            const SizedBox(height: 12),
            _ShortcutTile(
              icon: Icons.people,
              label: 'Friends',
              onTap: () => _openWip(context, 'Friends'),
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
          Text(
            label,
            style: const TextStyle(
              color: AppColors.parchmentBeige,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCountTile extends StatelessWidget {
  final String uid;
  const _WorkoutCountTile({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CompletedWorkout>>(
      stream: DatabaseService().getUserCompletedWorkouts(uid),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? '${snapshot.data!.length}' : '-';
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

  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

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

class _ProfileAvatar extends StatefulWidget {
  final String uid;
  final String initial;
  final String? photoBase64;

  const _ProfileAvatar({
    required this.uid,
    required this.initial,
    required this.photoBase64,
  });

  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;

  String? _decodedFrom;
  Uint8List? _bytes;

  Uint8List? _photoBytes() {
    final raw = widget.photoBase64;
    if (raw == null || raw.isEmpty) return null;

    if (raw != _decodedFrom) {
      try {
        _bytes = base64Decode(raw);
      } catch (_) {
        _bytes = null;
      }
      _decodedFrom = raw;
    }
    return _bytes;
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pick(ImageSource source) async {
    setState(() => _busy = true);
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (bytes.length > 700 * 1024) {
        _toast('That photo is too large. Please pick a smaller one.');
        return;
      }

      await DatabaseService().updateProfilePhoto(widget.uid, base64Encode(bytes));
      _toast('Profile photo updated!');
    } catch (e) {
      _toast('Could not update your photo. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    setState(() => _busy = true);
    try {
      await DatabaseService().updateProfilePhoto(widget.uid, null);
      _toast('Profile photo removed.');
    } catch (e) {
      _toast('Could not remove your photo. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.forgeSlate,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.emberOrange),
                title: const Text('Choose from gallery', style: TextStyle(color: AppColors.warmIvory)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pick(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: AppColors.emberOrange),
                title: const Text('Take a photo', style: TextStyle(color: AppColors.warmIvory)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pick(ImageSource.camera);
                },
              ),
              if (_photoBytes() != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: AppColors.emberOrange),
                  title: const Text('Remove photo', style: TextStyle(color: AppColors.warmIvory)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _remove();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _photoBytes();

    return GestureDetector(
      onTap: _busy ? null : _showOptions,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.questGold, width: 2),
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.forgeSlate,
              backgroundImage: bytes != null ? MemoryImage(bytes) : null,
              child: bytes == null
                  ? Text(
                      widget.initial,
                      style: const TextStyle(
                        color: AppColors.warmIvory,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          if (_busy)
            const CircularProgressIndicator()
          else
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.emberOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, size: 16, color: AppColors.warmIvory),
              ),
            ),
        ],
      ),
    );
  }
}

class _EquippedOutfitName extends StatelessWidget {
  final String uid;
  const _EquippedOutfitName({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Equipment?>(
      stream: DatabaseService().getEquippedItemStream(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Outfit: Unavailable', style: TextStyle(color: AppColors.parchmentBeige));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Outfit: Loading...', style: TextStyle(color: AppColors.parchmentBeige));
        }

        final item = snapshot.data;
        return Text(
          'Outfit: ${item?.name ?? 'None'}',
          style: const TextStyle(color: AppColors.parchmentBeige),
        );
      },
    );
  }
}
