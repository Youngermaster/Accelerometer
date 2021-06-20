import 'package:accelerometer/pages/home/home_page_animator.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Accelerometer',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomePageAnimator(),
    ),
  );
}
