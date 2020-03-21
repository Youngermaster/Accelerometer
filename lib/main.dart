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
      home: Index(storage: Storage(), title: 'ACCELEROMETER'),
    ),
  );
}