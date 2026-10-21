import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/models/store_item.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_bar.dart';

class SlayerCustomize extends StatefulWidget {
  const SlayerCustomize({super.key});

  @override
  State<SlayerCustomize> createState() => _SlayerCustomizeState();
}

class _SlayerCustomizeState extends State<SlayerCustomize> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _loadingData = true;
  bool _saving = false;
  bool _loadFailed = false;
  String? _loadedUid;
  String? _outfitId;
  List<StoreItem> _outfits = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<myUser?>(context);
    final uid = user?.uid;
    if (uid != null && uid != _loadedUid) {
      _loadedUid = uid;
      _loadCustomization(uid);
    }
  }

  Future<void> _loadCustomization(String uid) async {
    if (!mounted) return;

    setState(() {
      _loadingData = true;
      _loadFailed = false;
    });

    try {
      final userRef = _db.collection('users').doc(uid);
      final slayerRef = userRef.collection('slayer').doc('SO1');

      final results = await Future.wait([
        slayerRef.get(),
        userRef.collection('inventory').get(),
        StoreItem.fetchCatalog(),
      ]);

      final slayerSnapshot = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final inventorySnapshot = results[1] as QuerySnapshot<Map<String, dynamic>>;
      final catalog = results[2] as List<StoreItem>;
      final slayerData = slayerSnapshot.data() ?? <String, dynamic>{};
      final savedName = (slayerData['slayer_name'] as String?)?.trim() ?? '';
      final equippedId = slayerData['item_equipped'] as String?;
      final ownedIds = inventorySnapshot.docs.map((doc) => doc.id).toSet();
      final ownedOutfits = catalog.where((item) => ownedIds.contains(item.id)).toList();

      final validEquippedId = ownedOutfits.any((item) => item.id == equippedId,)
          ? equippedId
          : null;

      if (!mounted) return;

      setState(() {
        _outfits = ownedOutfits;
        _outfitId = validEquippedId;
        _nameController.text = savedName.isNotEmpty ? savedName : 'Slayer';
        _loadingData = false;
        _loadFailed = false;
      });
    } catch (e) {
      debugPrint('Failed to load Slayer customization: $e');

      if (!mounted) return;

      setState(() {
        _loadingData = false;
        _loadFailed = true;
      });
    }
  }

  Future<void> _save(String uid) async {
    if (!_formKey.currentState!.validate()) return;

    final slayerName = _nameController.text.trim();

    if (_outfitId != null && !_outfits.any((item) => item.id == _outfitId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not own the selected outfit.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {final slayerRef = _db.collection('users').doc(uid).collection('slayer').doc('SO1');

      await slayerRef.set({
        'slayer_name': slayerName,
        if (_outfitId != null) 'item_equipped': _outfitId,
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Slayer customization saved!'),
        ),
      );
      Navigator.pop(context);

    } catch (e) {
      debugPrint('Failed to save Slayer customization: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save customization. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<myUser?>(context);
    final uid = user?.uid;
    StoreItem? selected;

    for (final outfit in _outfits) {
      if (outfit.id == _outfitId) {
        selected = outfit;
        break;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.obsidianBlack,
      appBar: MyAppBar(),
      body: _loadingData ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.questGold,
        ),
      ) : _loadFailed ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 44,
                color: AppColors.emberOrange,
              ),
              const SizedBox(height: 12),
              const Text(
                'Could not load your customization.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.warmIvory,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: uid == null ? null : () => _loadCustomization(uid),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ) : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Slayer preview
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.forgeSlate,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.hearthBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 156,
                      height: 156,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.darkTavernGreen,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.parchmentBeige,
                          width: 2,
                        ),
                      ),
                      child: selected != null && selected.imagePath.isNotEmpty ? Image.asset(
                        selected.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace,) {
                          return const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.warmIvory,
                            size: 64,
                          );
                        },
                      )
                          : const Icon(
                        Icons.person,
                        size: 80,
                        color: AppColors.warmIvory,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _nameController.text.trim().isEmpty ? 'Slayer' : _nameController.text.trim(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.warmIvory,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //slayer name
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.forgeSlate,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.hearthBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Slayer Name',
                      style: TextStyle(
                        color: AppColors.warmIvory,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your Slayer name',
                        hintStyle: const TextStyle(
                          color: Colors.blueGrey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.hearthBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.flameOrange,
                            width: 3,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final name = value?.trim() ?? '';

                        if (name.isEmpty) {
                          return 'Please enter a valid Slayer name';
                        }

                        if (name.length < 3 || name.length > 16) {
                          return 'Name must be between 3 - 16 characters';
                        }

                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //outfit selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.forgeSlate,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.hearthBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Your Outfit',
                      style: TextStyle(
                        color: AppColors.warmIvory,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                      RadioGroup<String>(
                        groupValue: _outfitId,
                        onChanged: (value) {
                          setState(() => _outfitId = value);
                        },
                        child: Column(
                          children: _outfits.map((outfit) {
                            final isSelected =
                                outfit.id == _outfitId;

                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              color: isSelected ? AppColors.hearthStone : AppColors.forgeSlate,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected ? AppColors.questGold : AppColors.hearthBorder,
                                  width: isSelected ? 2 : 1.5,
                                ),
                              ),
                              clipBehavior:
                              Clip.antiAlias,
                              child: RadioListTile<String>(
                                value: outfit.id,
                                activeColor: AppColors.questGold,
                                contentPadding:
                                const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                title: Text(
                                  outfit.name,
                                  style: const TextStyle(
                                    color: AppColors.warmIvory,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                )
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving || uid == null ? null : () => _save(uid),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.flameOrange,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: Text(
                    _saving ? 'Saving...' : 'Save Changes',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}