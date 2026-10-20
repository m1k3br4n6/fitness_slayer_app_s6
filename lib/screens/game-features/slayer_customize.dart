import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/models/store_item.dart';
import 'package:fitness_slayer_01/services/database_service.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Lets the player rename their slayer and equip an outfit they own.
class SlayerCustomize extends StatefulWidget {
  const SlayerCustomize({super.key});

  @override
  State<SlayerCustomize> createState() => _SlayerCustomizeState();
}

class _SlayerCustomizeState extends State<SlayerCustomize> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _initialised = false;
  bool _saving = false;
  String? _outfitId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Fill the form from Firestore once, so live updates don't wipe unsaved edits.
  void _loadFrom(Map<String, dynamic> data, List<String> owned) {
    if (_initialised) return;
    _initialised = true;
    final saved = (data['slayer_name'] as String?)?.trim() ?? '';
    _nameController.text =
    saved.isNotEmpty ? saved : (data['username'] as String?) ?? 'Slayer';
    final outfit = data['equipped_outfit'] as String?;
    _outfitId = outfit != null && owned.contains(outfit) ? outfit : null;
  }

  Future<void> _save(String uid) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await DatabaseService().updateSlayerCustomization(
        uid,
        slayerName: _nameController.text.trim(),
        outfitId: _outfitId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Slayer updated!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save your slayer. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDoc = Provider.of<DocumentSnapshot?>(context);
    final user = Provider.of<myUser?>(context);

    if (userDoc == null || user == null) {
      return const Scaffold(
        backgroundColor: AppColors.obsidianBlack,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = userDoc.exists
        ? (userDoc.data() as Map<String, dynamic>? ?? <String, dynamic>{})
        : <String, dynamic>{};
    final owned = List<String>.from(data['inventory'] ?? const []);
    _loadFrom(data, owned);

    final outfits = storeCatalog
        .where((i) => i.category == StoreCategory.outfit && owned.contains(i.id))
        .toList();
    final selected = findStoreItem(_outfitId);

    return Scaffold(
      backgroundColor: AppColors.obsidianBlack,
      appBar: AppBar(
        title: const Text('Customize Slayer'),
        iconTheme: const IconThemeData(color: AppColors.warmIvory),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview
            Center(
              child: Column(
                children: [
                  Image.asset('assets/images/test_slayer_sprite.png', height: 140),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _nameController,
                    builder: (context, value, _) => Text(
                      value.text.trim().isEmpty ? 'Unnamed Slayer' : value.text.trim(),
                      style: const TextStyle(
                        color: AppColors.warmIvory,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(selected?.icon ?? Icons.checkroom,
                          size: 18, color: AppColors.emberOrange),
                      const SizedBox(width: 4),
                      Text(
                        selected?.name ?? 'No outfit',
                        style: const TextStyle(color: AppColors.parchmentBeige),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const _SectionLabel('Slayer name'),
            TextFormField(
              controller: _nameController,
              maxLength: 16,
              style: const TextStyle(color: AppColors.warmIvory),
              decoration: const InputDecoration(hintText: 'Enter a name'),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.length < 2) return 'Name must be at least 2 characters';
                return null;
              },
            ),
            const SizedBox(height: 8),

            const _SectionLabel('Outfit'),
            if (outfits.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "You don't own any outfits yet. Visit the store!",
                  style: TextStyle(color: AppColors.parchmentBeige),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AppColors.forgeSlate,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hearthBorder),
                ),
                child: Column(
                  children: [
                    _outfitTile(null, 'No outfit', Icons.block, '', null),
                    for (final item in outfits)
                      _outfitTile(item.id, item.name, item.icon, item.description, item.rarity),
                  ],
                ),
              ),

            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : () => _save(user.uid),
                icon: _saving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.check),
                label: const Text('Save slayer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _outfitTile(String? id, String name, IconData icon, String subtitle, Rarity? rarity) {
    final isSelected = id == _outfitId;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.questGold : AppColors.emberOrange),
      title: Text(name, style: const TextStyle(color: AppColors.warmIvory)),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
        '${rarity!.label} · $subtitle',
        style: const TextStyle(color: AppColors.parchmentBeige, fontSize: 12),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.questGold) : null,
      onTap: () => setState(() => _outfitId = id),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.questGold,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}