import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/services/database_service.dart';
import 'package:fitness_slayer_01/models/equipment.dart';

class SlayerEquipmentProvider extends ChangeNotifier {
  StreamSubscription<Equipment?>? _subscription;
  Equipment? currentEquipment;
  bool isLoading = true;

  String get idleSpritePath {
    final rawPath = currentEquipment?.idleSheetPath ?? 'idle/knight_idle_red_spritesheet';
    return rawPath.replaceAll('assets/spritesheets/', '').replaceAll('.png', '');
  }

  String get attackSpritePath {
    final rawPath = currentEquipment?.attackSheetPath ?? 'attack/knight_attack_red_spritesheet';
    return rawPath.replaceAll('assets/spritesheets/', '').replaceAll('.png', '');
  }

  String get equippedClass {
    return currentEquipment?.classType?? 'knight';
  }

  void initializeListener(String userId) {
    _subscription?.cancel();
    isLoading = true;

    if (userId.isNotEmpty) {
      _subscription = DatabaseService().getEquippedItemStream(userId).listen((equipment) {
        currentEquipment = equipment;
        isLoading = false;
        notifyListeners(); // Updates every screen
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}