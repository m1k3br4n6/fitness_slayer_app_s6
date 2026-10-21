import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  //  the user's profile photo is shown at the left of the bar,and tapping it guides you to the profile tab
  final VoidCallback? onAvatarTap;

  const MyAppBar({super.key, this.actions, this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    // Get the current user's document from the stream
    // TODO: Verify if Provider.of<DocumentSnapshot?> provides null or the new user snapshot immediately on account switch.
    final userData = Provider.of<DocumentSnapshot?>(context);

    String username = '';
    int level = 1;
    Uint8List? photoBytes;

    if (userData != null && userData.exists) {
      final data = userData.data() as Map<String, dynamic>;
      username = data['username'] ?? 'Slayer';
      int rawLevel = (data['level'] as num?)?.toInt() ?? 1;
      int rawXp = (data['xp'] as num?)?.toInt() ?? 0;

      // Calculate effective level based on 100 XP per level
      level = (rawLevel < 1 ? 1 : rawLevel) + (rawXp ~/ 100);

      final rawPhoto = data['photoBase64'] as String?;
      if (rawPhoto != null && rawPhoto.isNotEmpty) {
        try {
          photoBytes = base64Decode(rawPhoto);
        } catch (_) {
          photoBytes = null;
        }
      }
    }

    String appBarText = '$username lv$level';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return AppBar(
      leadingWidth: onAvatarTap == null ? null : 64,
      leading: onAvatarTap == null
          ? null
          : Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        child: GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.questGold, width: 1.5),
            ),
            child: CircleAvatar(
              backgroundColor: AppColors.forgeSlate,
              backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
              child: photoBytes == null
                  ? Text(
                initial,
                style: const TextStyle(
                  color: AppColors.warmIvory,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),
          ),
        ),
      ),
      title: Text(
        appBarText,
        style: TextStyle(
          color: AppColors.parchmentWhite,
          fontSize: 20,
        ),
      ),
      backgroundColor: AppColors.darkTavernGreen,
      elevation: 0.0,
      actions: actions, // displays custom action buttons
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}