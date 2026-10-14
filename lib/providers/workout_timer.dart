import 'dart:async';
import 'package:flutter/material.dart';

class WorkoutTimerProvider extends ChangeNotifier {

  // WORKOUT TIMER
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _workoutTimer;

  bool get isRunning => _stopwatch.isRunning;

  String get formattedTime {
    final milli = _stopwatch.elapsedMilliseconds;
    int seconds = ((milli ~/ 1000) % 60);
    int minutes = (milli ~/ 60000) % 60;
    int hours = (milli ~/ 3600000);

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  int get elapsedMinutes {
    return _stopwatch.elapsed.inMinutes;
  }

  void start() {
    if (_stopwatch.isRunning) return;

    _stopwatch.start();
    _workoutTimer?.cancel();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      notifyListeners();
    });
    notifyListeners();
  }

  void stopAndReset() {
    _stopwatch.stop();
    _stopwatch.reset();
    _workoutTimer?.cancel();
    notifyListeners();
  }

  // REST TIMER

  int _restSecondsRemaining = 0;
  Timer? _restTimer;
  bool _isRestRunning = false;
  bool _isRestPaused = false;

  int get restSecondsRemaining => _restSecondsRemaining;
  bool get isRestRunning => _isRestRunning;
  bool get isRestPaused => _isRestPaused;

  // Formats rest time nicely as MM:SS
  String get formattedRestTime {
    if (_restSecondsRemaining <= 0) return "00:00";
    int minutes = (_restSecondsRemaining ~/ 60) % 60;
    int seconds = _restSecondsRemaining % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void startRest(int seconds) {
    // Cleanly cancel any existing rest timer to prevent duplicate ticking loops
    _restTimer?.cancel();
    _restSecondsRemaining = seconds;
    _isRestRunning = true;
    _isRestPaused = false;
    notifyListeners();

    _startTimerLoop();
  }

  void addRestSeconds(int seconds) {
    if (!_isRestRunning && _restSecondsRemaining <= 0) return;

    _restSecondsRemaining += seconds;
    if (_restSecondsRemaining <= 0) {
      stopRest();
    } else {
      notifyListeners();
    }
  }

  // Private helper to handle the ticking loop
  void _startTimerLoop() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining > 0) {
        _restSecondsRemaining--;
        notifyListeners();
      } else {
        stopRest();
      }
    });
  }

  // PAUSE METHOD
  void pauseRest() {
    if (!_isRestRunning || _isRestPaused) return;

    _restTimer?.cancel();
    _isRestPaused = true;
    notifyListeners();
  }

  // RESUME METHOD
  void resumeRest() {
    if (!_isRestPaused) return;

    _isRestPaused = false;
    _startTimerLoop();
    notifyListeners();
  }

  // RESTART METHOD
  void restartRest(int seconds) {
    stopRest();
    startRest(seconds);
  }

  void stopRest() {
    _restTimer?.cancel();
    _isRestRunning = false;
    _isRestPaused = false;
    _restSecondsRemaining = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }
}
