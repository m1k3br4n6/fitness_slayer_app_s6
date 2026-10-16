import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  const MyAppBar({super.key, this.actions});

  @override
  Widget build(BuildContext context) {
    // Get the current user's document from the stream
    final userData = Provider.of<DocumentSnapshot?>(context);

    String username = '';
    int level = 0;

    if (userData != null && userData.exists) {
      final data = userData.data() as Map<String, dynamic>;
      username = data['username'] ?? '[user_not_found]';
      level = data['level'] ?? 0;
    }

    String appBarText = '$username  (Lv. $level)';

    return AppBar(
      title: Text(
        appBarText,
        style: TextStyle(
          color: AppColors.parchmentWhite,
          fontSize: 20,
        ),
      ),
      backgroundColor: AppColors.darkTavernGreen,
      elevation: 0.0,
      actions: actions, //displays custom action buttons
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}