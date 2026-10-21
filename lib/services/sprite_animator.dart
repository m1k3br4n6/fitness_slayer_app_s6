import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


//HOW TO USE (file na,e, without ".png")
//SpriteAnimator.play('knight_idle')
//SpriteAnimator.play('knight_idle, scale: 6')
const String spriteFolder = '';

class SpriteAnimator extends StatefulWidget
{
  final String  name;
  final double  scale;

  const SpriteAnimator ({super.key, required this.name, this.scale = 4});

  static Widget play(String name, {double scale = 4})
  {
    return SpriteAnimator(key: ValueKey(name), name: name, scale: scale);
  }

  @override
  State<SpriteAnimator> createState() => _SpriteAnimatorState();
}

class _SpriteAnimatorState extends State<SpriteAnimator>
{
  Timer? timer;
  int frameCount = 0;
  double frameSize = 0;
  int currentFrame = 0;

  @override
  void initState()
  {
    super.initState();
    loadSheet();
  }

  Future<void> loadSheet() async
  {
    String path = ''; /// insert path

    var data = await rootBundle.load(path);
    var image = await decodeImageFromList(data.buffer.asUint8List());

    if (!mounted) return;

    setState(()
    {
     frameSize = image.height.toDouble();
     frameCount = image.width ~/image.height;
    });

    timer = Timer.periodic(const Duration(milliseconds: 150), (t)
    {
      setState(()
      {
        currentFrame = currentFrame + 1;

        if (currentFrame >= frameCount)
        {
          currentFrame = 0;
        }
        });
      });
}

@override
void dispose()
{
  timer?.cancel();
  super.dispose();
}

@override
Widget build(BuildContext context)
{
  if (frameCount == 0)
    {
      return const SizedBox();
    }

  double shownSize = frameSize * widget.scale;

  double sheetWidth = shownSize * frameCount;

  double moveLeft = currentFrame * shownSize;

  return SizedBox(
    width: shownSize,
    height: shownSize,
    child: Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          left: -moveLeft,
          top: 0,
          child: Image.asset(
            'sprite folder',
            width: sheetWidth,
            height: shownSize,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ),
        ),
      ],
    ),
  );
 }
}