import 'package:cloud_firestore/cloud_firestore.dart';

class SideQuestEntry {
  final String text;
  final int xp;
  final int coins;
  final DateTime dateCompleted;

  const SideQuestEntry({
    required this.text,
    required this.xp,
    required this.coins,
    required this.dateCompleted,
  });

  factory SideQuestEntry.fromMap(Map<String, dynamic> map) {
    final rawDate = map['dateCompleted'];
    return SideQuestEntry(
      text: map['text'] as String? ?? 'Side Quest',
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      coins: (map['coins'] as num?)?.toInt() ?? 0,
      dateCompleted: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
    );
  }
}