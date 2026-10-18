import 'package:flutter/material.dart';
import 'app_colors.dart';

const textInputFieldDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 4.0),
  ),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.flameOrange, width: 4.0),
  ),
);
