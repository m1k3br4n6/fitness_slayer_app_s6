import 'dart:async';
import 'package:flutter/material.dart';

const String barFolder = 'assets/spritesheets/bars/';

// State machine pixel art bar widget for rendering HP and ATK
class BarSpriteWidget extends StatefulWidget {
  final String barName;
  final int frameCount;
  
  // Percentage progress for HP bars.
  final double? progress; 

  final bool isAttackBar;
  final bool isTurn;
  final Duration drainDuration;

  const BarSpriteWidget({
    super.key,
    required this.barName,
    required this.frameCount,
    this.progress,
    this.isAttackBar = false,
    this.isTurn = false,
    this.drainDuration = const Duration(milliseconds: 800),
  });

  @override
  State<BarSpriteWidget> createState() => _BarSpriteWidgetState();
}

class _BarSpriteWidgetState extends State<BarSpriteWidget> {
  int _currentFrame = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateFrameLogic(isInit: true);
  }

  @override
  void didUpdateWidget(BarSpriteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAttackBar) {
      if (widget.isTurn != oldWidget.isTurn) {
        _updateFrameLogic();
      }
    } else if (widget.progress != oldWidget.progress) {
      _updateFrameLogic();
    }
  }

  // Updates frame index based on bar type
  // HP static mapping and changing and ATK turn drains in 2s
  void _updateFrameLogic({bool isInit = false}) {
    if (widget.isAttackBar) {
      if (widget.isTurn) {
        // Turn started and reset to full atk to start
        setState(() { _currentFrame = 0; });
        _startDrain();
      } else {
        // Idle turn will Show Full frame on launch else empty if atk phase is done
        _timer?.cancel();
        setState(() {
          _currentFrame = isInit ? 0 : widget.frameCount - 1;
        });
      }
    } else {
      // HP bar maps health ratio
      _timer?.cancel();
      setState(() {
        _currentFrame = ((widget.progress ?? 1.0).clamp(0.0, 1.0) * (widget.frameCount - 1))
            .round()
            .clamp(0, widget.frameCount - 1);
      });
    }
  }

  // Timer animation for attack bar frames over using drainDuration
  void _startDrain() {
    _timer?.cancel();
    int interval = widget.drainDuration.inMilliseconds ~/ (widget.frameCount > 0 ? widget.frameCount : 1);
    
    _timer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentFrame < widget.frameCount - 1) {
        setState(() {
          _currentFrame++;
        });
      } else {
        timer.cancel(); // Stop at final empty frame
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculates alignment  to frame the target sprite frame
    double step = widget.frameCount > 1 ? 2.0 / (widget.frameCount - 1) : 0.0;
    double alignX = -1.0 + (_currentFrame * step);

    return FittedBox(
      fit: BoxFit.contain, // Bounds and preserves pixel-art aspect ratio
      alignment: Alignment.centerLeft,
      child: ClipRect(
        child: Align(
          alignment: Alignment(alignX, 0.0),
          widthFactor: 1.0 / widget.frameCount, // Viewport clips exactly 1 frame width
          child: Image.asset(
            '$barFolder${widget.barName}.png',
            filterQuality: FilterQuality.none, // Retains crisp pixel-art edges
          ),
        ),
      ),
    );
  }
}
