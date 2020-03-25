import 'package:accelerometer/pages/home/home_page_animator.dart';
import 'package:flutter/material.dart';
import 'package:accelerometer/views/index.dart';
import 'package:accelerometer/models/storage.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Accelerometer',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      // home: Index(storage: Storage(), title: 'ACCELEROMETER'),
      home: HomePageAnimator(),
    ),
  );
}