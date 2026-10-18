import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bar.dart';

class equipmentManage extends StatefulWidget {
  const equipmentManage({super.key});

  @override
  State<equipmentManage> createState() => _equipmentManageState();
}

class _equipmentManageState extends State<equipmentManage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.obsidianBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Equipment management page',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
