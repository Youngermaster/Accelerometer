import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:accelerometer/models/storage.dart';
import 'package:accelerometer/pages/home/home_page.dart';

class HomePageAnimator extends StatefulWidget {
  @override
  _HomePageAnimatorState createState() => _HomePageAnimatorState();
}

class _HomePageAnimatorState extends State<HomePageAnimator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomePage(controller: _controller, storage: Storage());
  }
}
