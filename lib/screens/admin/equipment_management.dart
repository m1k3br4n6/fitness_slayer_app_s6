import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_slayer_01/screens/admin/equipment_add.dart';
import 'package:fitness_slayer_01/services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/loading.dart';

class EquipmentList extends StatefulWidget {
  const EquipmentList({super.key});

  @override
  State<EquipmentList> createState() => _EquipmentListState();
}

class _EquipmentListState extends State<EquipmentList> {
  bool loading = false;

  final CollectionReference<Map<String, dynamic>> equipmentCollection =
  FirebaseFirestore.instance.collection('equipment_items');

  Future<void> _deleteEquipment(String itemId, String itemName,) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.obsidianBlack,
        title: const Text(
          'Delete Equipment?',
          style: TextStyle(color: AppColors.parchmentWhite),
        ),
        content: Text(
          'Are you sure you want to delete "$itemName"?',
          style: const TextStyle(color: AppColors.parchmentWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    await DatabaseService().deleteEquipment(itemId);
  }

  Widget _buildEquipmentCard(String itemId, Map<String, dynamic> data,) {
    final String name = data['name'].toString();
    final String description = data['description'].toString();
    final String spritePath = data['sprite_image_path'];
    final num price = data['price'] is num ? data['price'] as num : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkTavernGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.flameOrange, width: 4.0,),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //equipment image
          Container(
            width: 90,
            height: 90,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              spritePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(
                Icons.broken_image,
                color: AppColors.parchmentWhite,
                size: 40,
              ),
            ),
          ),

          const SizedBox(width: 16),

          //equipment info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color:  AppColors.parchmentWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: $itemId  Price: $price Coins',
                  style: const TextStyle(
                    color:  AppColors.parchmentWhite,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.parchmentWhite),
                ),
                const SizedBox(height: 16),

                //delete button
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => _deleteEquipment(itemId, name),
                    label: const Text('Delete', style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: AppColors.obsidianBlack,
      appBar: const MyAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 24,
        ),
        child: Column(
          children: [
            //add equipment button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.flameOrange,
                  foregroundColor: AppColors.parchmentWhite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  setState(() => loading = true);

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const addEquipment(),
                    ),
                  );

                  if (mounted) {
                    setState(() => loading = false);
                  }
                },
                child: const Text(
                  'Add Equipment',
                  style: TextStyle(fontSize: 16),
                ),
              ),

            const SizedBox(height: 20),

            //live equipment list from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: equipmentCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Error loading equipment.',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Loading();
                  }

                  final equipment = snapshot.data?.docs ?? [];

                  if (equipment.isEmpty) {
                    return const Center(
                      child: Text(
                        'No equipment found.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: equipment.length,
                    itemBuilder: (context, index) {
                      final doc = equipment[index];

                      return _buildEquipmentCard(
                        doc.id,
                        doc.data(),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}