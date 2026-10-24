import 'package:flutter/foundation.dart';
import 'dart:async';

class ExpBarProvider extends ChangeNotifier {
  int _currentExp = 0;
  int _maxExp = 100;

  int get currentExp => _currentExp;
  int get maxExp => _maxExp;

  // Maps exp to 8 frames from sprite sheet
  int get currentFrame {
    if (_maxExp == 0) return 0;

    double percent = (_currentExp / _maxExp) * 100;

    if (percent >= 100) return 7;
    if (percent >= 90) return 6;
    if (percent >= 80) return 5;
    if (percent >= 60) return 4;
    if (percent >= 40) return 3;
    if (percent >= 20) return 2;
    if (percent >= 10) return 1;
    return 0; // 0%
  }

  // for static pages
  void setStaticExp(int exp, int max) {
    _currentExp = exp;
    _maxExp = max;
    notifyListeners();
  }

  // for level up pages
  Future<void> animateExpGain(int oldExp, int newExp, int max) async {
    _maxExp = max;
    _currentExp = oldExp;
    notifyListeners();

    int difference = newExp - oldExp;
    if (difference <= 0) return;

    //small chunk so bar loads up
    int step = (difference / 15).ceil();

    while (_currentExp < newExp) {
      await Future.delayed(const Duration(milliseconds: 60));
      _currentExp += step;

      if (_currentExp > newExp) {
        _currentExp = newExp;
      }
      notifyListeners();
      // Update when new step is reached
    }
  }
}
