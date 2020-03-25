import 'dart:async';

import 'package:flushbar/flushbar.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:accelerometer/models/storage.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:accelerometer/pages/home/home_page_enter_animation.dart';

class HomePage extends StatefulWidget {
  final HomePageEnterAnimation animation;
  final Storage storage;

  HomePage({
    Key key,
    @required AnimationController controller,
    @required this.storage,
  })  : animation = HomePageEnterAnimation(controller),
        super(key: key);

  @override
  _HomePageState createState() => _HomePageState(animation);
}

class _HomePageState extends State<HomePage> {
  HomePageEnterAnimation animation;
  _HomePageState(this.animation);
  int peridiocity;
  bool isRunning;

  AccelerometerEvent accelerometerEvent;
  StreamSubscription accelerometerSubscription;

  var stopwatch;

  final Email _email = Email(
    body: 'In this mail I attach the Accelerometer data',
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
      peridiocity = 100;
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
        onPressed: () async => {
          if (!isRunning)
            {
              await FlutterEmailSender.send(_email),
              await widget.storage.flushDocument(),
            }
          else
            {
              Flushbar(
                flushbarPosition: FlushbarPosition.TOP,
                title: "Accelerometer",
                message: "The accelerometer is running",
                icon: Icon(
                  Icons.warning,
                  color: Colors.red,
                ),
                duration: Duration(seconds: 2),
              )..show(context)
            }
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
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Opacity(
                        opacity: animation.titleOpacity.value,
                        child: pauseButton(),
                      ),
                      SizedBox(height: 10),
                      Opacity(
                          opacity: animation.titleOpacity.value,
                          child: placeholderBoxTitle(
                              28, 150, Alignment.centerLeft, "pause")),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Opacity(
                        opacity: animation.titleOpacity.value,
                        child: restartButton(),
                      ),
                      SizedBox(height: 10),
                      Opacity(
                          opacity: animation.titleOpacity.value,
                          child: placeholderBoxTitle(
                              28, 150, Alignment.centerLeft, "restart")),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Opacity(
                  opacity: animation.textOpacity.value,
                  child: placeholderBoxText(
                      150, double.infinity, Alignment.centerLeft)),
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
          'Seconds: ${stopwatch.elapsedMilliseconds ~/ 1000}',
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
        child: Opacity(
            opacity: animation.titleOpacity.value, child: elapsedTime()),
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
              onPressed: () async {
                isRunning = true;
                stopwatch.start();
                new Timer.periodic(
                    Duration(milliseconds: peridiocity),
                    (Timer t) => {
                          if (isRunning)
                            {
                              _useAccelerometer(),
                              widget.storage.writeAccelerometer(
                                  '${accelerometerEvent.x},${accelerometerEvent.y},${accelerometerEvent.z},${stopwatch.elapsedMilliseconds}\n')
                            }
                          else
                            t.cancel()
                        });

                Flushbar(
                  flushbarPosition: FlushbarPosition.TOP,
                  title: "Accelerometer",
                  message: "Accelerometer Started",
                  duration: Duration(seconds: 2),
                )..show(context);
              },
              backgroundColor: Colors.red.shade700,
              elevation: 10.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget restartButton() {
    return Container(
      height: 50.0,
      width: 50.0,
      child: FittedBox(
        child: FloatingActionButton(
          child: Center(
            child: Icon(Icons.refresh),
          ),
          onPressed: () async {
            setState(() {
              stopwatch.stop();
              stopwatch.reset();
            });
            await widget.storage.flushDocument();
            isRunning = false;
            accelerometerSubscription.cancel();
            accelerometerSubscription = null;
            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              title: "Accelerometer",
              message: "Accelerometer Restarted",
              duration: Duration(seconds: 2),
            )..show(context);
          },
          backgroundColor: Colors.red,
          elevation: 10.0,
        ),
      ),
    );
  }

  Widget pauseButton() {
    return Container(
      height: 50.0,
      width: 50.0,
      child: FittedBox(
        child: FloatingActionButton(
          child: Center(
            child: Icon(Icons.pause),
          ),
          onPressed: () async {
            stopwatch.stop();
            accelerometerSubscription.pause();
            isRunning = false;
            // accelerometerSubscription.cancel();
            // accelerometerSubscription = null;
            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              title: "Accelerometer",
              message: "Accelerometer Paused",
              duration: Duration(seconds: 2),
            )..show(context);
          },
          backgroundColor: Colors.red,
          elevation: 10.0,
        ),
      ),
    );
  }

  Align placeholderBoxTitle(
      double height, double width, Alignment alignment, String title) {
    return Align(
      alignment: alignment,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey.shade300,
        ),
        child: Center(
            child: Opacity(
          opacity: animation.textOpacity.value,
          child: Text(
            title,
            style: TextStyle(fontSize: 15.0, color: Colors.black),
          ),
        )),
      ),
    );
  }

  Align placeholderBoxText(double height, double width, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey.shade300,
        ),
        child: Center(
            child: Opacity(
                opacity: animation.textOpacity.value, child: peridocity())),
      ),
    );
  }

  Widget peridocity() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          "Periodicity",
          style: TextStyle(fontSize: 35.0, color: Colors.black),
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                "$peridiocity milliseconds",
                style: TextStyle(fontSize: 15.0, color: Colors.black),
              ),
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                color: Colors.red,
                textColor: Colors.white,
                onPressed: () {
                  createAlertDialog(context).then((onValue) {
                    setState(() {
                      peridiocity = onValue;
                    });
                  });
                },
                child: Text(
                  "edit",
                  style: TextStyle(fontSize: 15.0, color: Colors.white),
                ),
              )
            ]),
      ],
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
                  try {
                    Navigator.of(context).pop(
                        int.parse(customController.text.toString().trim()));
                  } catch (e) {
                    Flushbar(
                      flushbarPosition: FlushbarPosition.TOP,
                      title: "ERROR",
                      message: "Write just a number",
                      icon: Icon(
                        Icons.warning,
                        color: Colors.red,
                      ),
                      duration: Duration(seconds: 2),
                    )..show(context);
                  }
                },
              )
            ],
          );
        });
  }
}
