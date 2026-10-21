import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScrollingBackground extends StatefulWidget {
  final String imageName;
  final int scrollDurationSeconds; 

  const ScrollingBackground({
    super.key,
    required this.imageName,
    this.scrollDurationSeconds = 15,
  });

  @override
  State<ScrollingBackground> createState() => _ScrollingBackgroundState();
}

class _ScrollingBackgroundState extends State<ScrollingBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double? imageWidth;
  double? imageHeight;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.scrollDurationSeconds),
    )..repeat();
    _loadImage();
  }

  // Load the raw image data so we can calculate exact pixel scaling
  Future<void> _loadImage() async {
    final data = await rootBundle.load('assets/spritesheets/${widget.imageName}.png');
    final image = await decodeImageFromList(data.buffer.asUint8List());
    if (mounted) {
      setState(() {
        imageWidth = image.width.toDouble();
        imageHeight = image.height.toDouble();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (imageWidth == null || imageHeight == null) {
      return const SizedBox(); // Empty while loading dimensions
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Scale the original width by however much the height needs to stretch to fill the arena
        final scale = constraints.maxHeight / imageHeight!;
        final scaledWidth = imageWidth! * scale;

        return ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    bottom: 0,
                    // Slide left by exactly one scaled image width for a perfect seamless loop
                    left: -_controller.value * scaledWidth,
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/spritesheets/${widget.imageName}.png',
                          width: scaledWidth,
                          height: constraints.maxHeight,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.none, // Keep pixel art crisp
                        ),
                        Image.asset(
                          'assets/spritesheets/${widget.imageName}.png',
                          width: scaledWidth,
                          height: constraints.maxHeight,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.none,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
