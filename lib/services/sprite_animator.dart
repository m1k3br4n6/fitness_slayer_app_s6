import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// HOW TO USE (file name, without ".png")
// SpriteAnimator.play('knight_idle')
// SpriteAnimator.play('knight_idle, scale: 6')
const String spriteFolder = 'assets/spritesheets/';

class SpriteAnimator extends StatefulWidget {
  final String name;
  final double scale;
  final int fps;
  final bool pingPong;
  final int? frameCount;
  final int? staticFrame;

  const SpriteAnimator({
    super.key,
    required this.name,
    this.scale = 4,
    this.fps = 7,
    this.pingPong = false,
    this.frameCount,
    this.staticFrame,
  });

  static Widget play(
    String name, {
    double scale = 4,
    int fps = 7,
    bool pingPong = false,
    int? frameCount,
    int? staticFrame,
  }) {
    return SpriteAnimator(
      // Exclude staticFrame from key so state is retained when staticFrame updates
      key: ValueKey('$name-$scale-$fps-$pingPong-$frameCount'),
      name: name,
      scale: scale,
      fps: fps,
      pingPong: pingPong,
      frameCount: frameCount,
      staticFrame: staticFrame,
    );
  }

  @override
  State<SpriteAnimator> createState() => _SpriteAnimatorState();
}

class _SpriteAnimatorState extends State<SpriteAnimator> {
  Timer? timer;
  int frameCount = 0;
  double frameWidth = 0;
  double frameHeight = 0;
  int currentFrame = 0;
  bool isVertical = false;

  @override
  void initState() {
    super.initState();
    currentFrame = widget.staticFrame ?? 0;
    loadSheet();
  }

  @override
  void didUpdateWidget(covariant SpriteAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.staticFrame != oldWidget.staticFrame && widget.staticFrame != null) {
      setState(() {
        currentFrame = widget.staticFrame!;
      });
    }
  }

  Future<void> loadSheet() async {
    String path = '$spriteFolder${widget.name}.png';

    try {
      var data = await rootBundle.load(path);
      var image = await decodeImageFromList(data.buffer.asUint8List());

      if (!mounted) return;

      final double w = image.width.toDouble();
      final double h = image.height.toDouble();

      setState(() {
        if (h > w) {
          isVertical = true;
          frameCount = widget.frameCount ?? (image.height ~/ image.width);
          frameWidth = w;
          frameHeight = h / frameCount;
        } else {
          isVertical = false;
          frameCount = widget.frameCount ?? (image.width ~/ image.height);
          frameHeight = image.height.toDouble();
          frameWidth = image.width / frameCount;
        }
      });

      if (widget.staticFrame != null) return;

      int step = 1;
      int intervalMs = (1000 / (widget.fps > 0 ? widget.fps : 7)).round();

      timer?.cancel();
      timer = Timer.periodic(Duration(milliseconds: intervalMs), (t) {
        if (!mounted) return;
        setState(() {
          if (widget.pingPong && frameCount > 1) {
            currentFrame += step;
            if (currentFrame >= frameCount - 1) {
              currentFrame = frameCount - 1;
              step = -1;
            } else if (currentFrame <= 0) {
              currentFrame = 0;
              step = 1;
            }
          } else {
            currentFrame = currentFrame + 1;
            if (currentFrame >= frameCount) {
              currentFrame = 0;
            }
          }
        });
      });
    } catch (e) {
      debugPrint('Error loading spritesheet at $path: $e');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (frameCount == 0) return const SizedBox();

    double shownWidth = frameWidth * widget.scale;
    double shownHeight = frameHeight * widget.scale;

    if (isVertical) {
      double sheetHeight = shownHeight * frameCount;
      double moveOffset = currentFrame * shownHeight;

      return SizedBox(
        width: shownWidth,
        height: shownHeight,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: 0,
              top: -moveOffset,
              child: Image.asset(
                '$spriteFolder${widget.name}.png',
                width: shownWidth,
                height: sheetHeight,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            ),
          ],
        ),
      );
    }

    double sheetWidth = shownWidth * frameCount;
    double moveLeft = currentFrame * shownWidth;

    return SizedBox(
      width: shownWidth,
      height: shownHeight,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: -moveLeft,
            top: 0,
            child: Image.asset(
              '$spriteFolder${widget.name}.png',
              width: sheetWidth,
              height: shownHeight,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),
        ],
      ),
    );
  }
}
