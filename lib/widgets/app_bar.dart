import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  const MyAppBar({super.key, this.actions});

  @override
  Widget build(BuildContext context) {
    // Get the current user's document from the stream
    final userData = Provider.of<DocumentSnapshot?>(context);

    String username = '';
    int level = 1;

    if (userData != null && userData.exists) {
      final data = userData.data() as Map<String, dynamic>;
      username = data['username'] ?? 'Slayer';
      int rawLevel = (data['level'] as num?)?.toInt() ?? 1;
      int rawXp = (data['xp'] as num?)?.toInt() ?? 0;
      
      // Calculate effective level based on 100 XP per level
      level = (rawLevel < 1 ? 1 : rawLevel) + (rawXp ~/ 100);
    }

    String appBarText = '$username  (Lv. $level)';

    return AppBar(
      title: Text(
        appBarText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.teal,
      elevation: 0.0,
      actions: actions, // displays custom action buttons
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
