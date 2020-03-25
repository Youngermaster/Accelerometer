import 'dart:async';

import 'package:flutter/material.dart';
import 'package:accelerometer/pages/home/home_page_enter_animation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:sensors/sensors.dart';

class HomePage extends StatefulWidget {
  final HomePageEnterAnimation animation;

  HomePage({
    Key key,
    @required AnimationController controller,
  })  : animation = HomePageEnterAnimation(controller),
        super(key: key);

  @override
  _HomePageState createState() => _HomePageState(animation);
}

class _HomePageState extends State<HomePage> {
  HomePageEnterAnimation animation;
  int _counter = 0;
  _HomePageState(this.animation);
  int peridiocity;
  bool isRunning;

  AccelerometerEvent accelerometerEvent;
  StreamSubscription accelerometerSubscription;

  var stopwatch;

  final Email _email = Email(
    body: 'Accelerometer data',
    subject: 'Accelerometer data',
    recipients: [''],
    cc: [''],
    bcc: [''],
    attachmentPath:
        '/storage/emulated/0/Android/data/com.grisu.accelerometer/files/data.txt',
    isHTML: false,
  );

  @override
  void initState() {
    super.initState();
    setState(() {
      isRunning = false;
      stopwatch = new Stopwatch();
      peridiocity = 1;
    });
  }

  @override
  void dispose() {
    accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: AnimatedBuilder(
          animation: animation.controller,
          builder: (context, child) => _buildAnimation(context, child, size)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _counter++;
          });
        },
        tooltip: 'Share',
        child: Icon(Icons.share),
      ),
    );
  }

  Widget _buildAnimation(BuildContext context, Widget child, Size size) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 250,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              topBar(animation.barHeight.value),
              startButton(size, animation.avaterSize.value)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              SizedBox(height: 60),
              Opacity(
                  opacity: animation.titleOpacity.value,
                  child: placeholderBox(28, 150, Alignment.centerLeft)),
              SizedBox(height: 8),
              Opacity(
                  opacity: animation.textOpacity.value,
                  child: placeholderBox(
                      200, double.infinity, Alignment.centerLeft)),
            ],
          ),
        ),
      ],
    );
  }

  Widget elapsedTime() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          'Elapsed time',
          style: TextStyle(fontSize: 40.0, color: Colors.white),
        ),
        Text(
          'Seconds: $_counter',
          style: TextStyle(fontSize: 15.0, color: Colors.white),
        ),
        SizedBox(),
      ],
    );
  }

  Container topBar(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.red,
      child: Center(
        child: elapsedTime(),
      ),
    );
  }

  Positioned startButton(Size size, double animationValue) {
    return Positioned(
      top: 200,
      left: size.width / 2 - 50,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(animationValue, animationValue, 1.0),
        child: Container(
          height: 100,
          width: 100,
          child: FittedBox(
            child: FloatingActionButton(
              child: Center(
                child: Icon(Icons.play_arrow),
              ),
              onPressed: () {},
              backgroundColor: Colors.red.shade700,
              elevation: 10.0,
            ),
          ),
        ),
      ),
    );
  }

  Align placeholderBox(double height, double width, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
  void _useAccelerometer() {
    if (accelerometerSubscription == null) {
      accelerometerSubscription =
          accelerometerEvents.listen((AccelerometerEvent event) {
        setState(() {
          accelerometerEvent = event;
        });
      });
    } else {
      // it has already ben created so just resume it
      accelerometerSubscription.resume();
    }
  }

  Future<int> createAlertDialog(BuildContext context) {
    TextEditingController customController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Periodicity'),
            content: TextField(
              controller: customController,
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text('Submit'),
                onPressed: () {
                  Navigator.of(context)
                      .pop(int.parse(customController.text.toString().trim()));
                },
              )
            ],
          );
        });
  }
}

// class HomePage extends StatelessWidget {
//   int _counter = 0;

//   HomePage({
//     Key key,
//     @required AnimationController controller,
//   })  : animation = HomePageEnterAnimation(controller),
//         super(key: key);
//   final HomePageEnterAnimation animation;

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       body: AnimatedBuilder(
//           animation: animation.controller,
//           builder: (context, child) => _buildAnimation(context, child, size)),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _counter++;
//           print(_counter);
//         },
//         tooltip: 'Share',
//         child: Icon(Icons.share),
//       ),
//     );
//   }

//   Widget _buildAnimation(BuildContext context, Widget child, Size size) {
//     return Column(
//       children: <Widget>[
//         SizedBox(
//           height: 250,
//           child: Stack(
//             overflow: Overflow.visible,
//             children: <Widget>[
//               topBar(animation.barHeight.value),
//               startButton(size, animation.avaterSize.value)
//             ],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             children: <Widget>[
//               SizedBox(height: 60),
//               Opacity(
//                   opacity: animation.titleOpacity.value,
//                   child: placeholderBox(28, 150, Alignment.centerLeft)),
//               SizedBox(height: 8),
//               Opacity(
//                   opacity: animation.textOpacity.value,
//                   child: placeholderBox(
//                       200, double.infinity, Alignment.centerLeft)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Container topBar(double height) {
//     return Container(
//       height: height,
//       width: double.infinity,
//       color: Colors.red,
//       child: Center(
//         child: Text("$_counter"),
//       ),
//     );
//   }

//   Positioned startButton(Size size, double animationValue) {
//     return Positioned(
//       top: 200,
//       left: size.width / 2 - 50,
//       child: Transform(
//         alignment: Alignment.center,
//         transform: Matrix4.diagonal3Values(animationValue, animationValue, 1.0),
//         child: Container(
//           height: 100,
//           width: 100,
//           child: FittedBox(
//             child: FloatingActionButton(
//               child: Center(
//                 child: Icon(Icons.play_arrow),
//               ),
//               onPressed: () {},
//               backgroundColor: Colors.red.shade700,
//               elevation: 10.0,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Align placeholderBox(double height, double width, Alignment alignment) {
//     return Align(
//       alignment: alignment,
//       child: Container(
//         height: height,
//         width: width,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(5),
//           color: Colors.grey.shade300,
//         ),
//       ),
//     );
//   }
// }
