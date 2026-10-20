import 'package:fitness_slayer_01/screens/admin/equipment_management.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/loading.dart';

class adminDashboard extends StatefulWidget {
  const adminDashboard({super.key});

  @override
  State<adminDashboard> createState() => _adminDashboardState();
}

class _adminDashboardState extends State<adminDashboard> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.obsidianBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(height: 20),

            const Text(
              'Administrator Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.flameOrange,
                foregroundColor: AppColors.parchmentWhite,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                setState(() => loading = true);

                //waits until page closes
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EquipmentList(),
                  ),
                );

                //if page still exists, mounted is true
                if (mounted) {
                  setState(() => loading = false);
                }
              },
              child: Text('Manage Equipment', style: TextStyle(color: AppColors.parchmentWhite, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
