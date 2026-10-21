import 'package:cloud_firestore/cloud_firestore.dart';

//item a user can buy in the store.
class StoreItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imagePath;

  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
  });

  //convert a Firestore document into a StoreItem.
  //factory is a type of constructor that allows for processing data and returning an object
  factory StoreItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc,) {
    final data = doc.data() ?? <String, dynamic>{};

    return StoreItem(
      id: doc.id,
      name: data['name'] as String? ?? 'Unknown Item',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toInt() ?? 0,
      imagePath: data['sprite_image_path'] as String? ?? '',
    );
  }

  //fetch the store catalog from Firestore.
  static Future<List<StoreItem>> fetchCatalog() async {
    final snapshot = await FirebaseFirestore.instance.collection('equipment_items').get();
    return snapshot.docs.map((doc) => StoreItem.fromFirestore(doc)).toList();
  }
}
