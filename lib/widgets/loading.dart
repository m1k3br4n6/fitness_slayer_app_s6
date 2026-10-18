import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../theme/app_colors.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.obsidianBlack,
      child: Center(
        child: SpinKitFadingCircle(
          color: Colors.blue,
          size: 100.0,
        ),
      ),
    );
  }
}
