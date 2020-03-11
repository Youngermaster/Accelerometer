import 'dart:io';
import 'dart:async';
import 'package:sensors/sensors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flushbar/flushbar.dart';
import 'package:accelerometer/models/storage.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class Index extends StatefulWidget {
  final Storage storage;
  final String title;

  Index({Key key, @required this.storage, this.title}) : super(key: key);

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  int _counter;
  bool isRunning;
  double _accelerometerX;
  double _accelerometerY;
  double _accelerometerZ;

  AccelerometerEvent accelerometerEvent;
  StreamSubscription accelerometerSubscription;

  var stopwatch = new Stopwatch();

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
    // widget.storage.readCounter().then((int value) {
    //   setState(() {
    //     _counter = value;
    //   });
    // });
  }

  @override
  void dispose() {
    accelerometerSubscription?.cancel();
    super.dispose();
  }

  // Future<File> _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  //   return widget.storage.writeCounter('$_counter');
  // }

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
    /*
    accelerometerEvents.listen((AccelerometerEvent event) {
      print("accelerometerEvents");
      _accelerometerX = event.x;
      _accelerometerY = event.y;
      _accelerometerZ = event.z;
      print(event);
      print("${stopwatch.elapsedMilliseconds}");
    });*/
  }

  void _pauseAccelerometer() {}

  void _userAccelerometer() {
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      // print("userAccelerometerEvents");
      // print(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  'ELAPSED TIME',
                  style: TextStyle(
                    fontSize: 35.0,
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  'Seconds: ${stopwatch.elapsedMilliseconds ~/ 1000}',
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
                Text(
                  'Milliseconds: ${stopwatch.elapsedMilliseconds}',
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  height: 50.0,
                  width: 50.0,
                  child: FittedBox(
                    child: FloatingActionButton(
                      child: Center(
                        child: Icon(Icons.play_arrow),
                      ),
                      onPressed: () async {
                        Flushbar(
                          flushbarPosition: FlushbarPosition.TOP,
                          title: "Accelerometer",
                          message: "Accelerometer Started",
                          duration: Duration(seconds: 2),
                        )..show(context);
                        isRunning = true;
                        stopwatch.start();
                        const oneSec = const Duration(milliseconds: 1);
                        new Timer.periodic(
                            oneSec,
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
                      },
                      backgroundColor: Colors.green,
                      elevation: 10.0,
                    ),
                  ),
                ),
                Container(
                  height: 50.0,
                  width: 50.0,
                  child: FittedBox(
                    child: FloatingActionButton(
                      child: Center(
                        child: Icon(Icons.pause),
                      ),
                      onPressed: () async {
                        Flushbar(
                          flushbarPosition: FlushbarPosition.TOP,
                          title: "Accelerometer",
                          message: "Accelerometer Paused",
                          duration: Duration(seconds: 2),
                        )..show(context);
                        stopwatch.stop();
                        accelerometerSubscription.pause();
                        isRunning = false;
                        // accelerometerSubscription.cancel();
                        // accelerometerSubscription = null;
                      },
                      backgroundColor: Colors.red,
                      elevation: 10.0,
                    ),
                  ),
                ),
                Container(
                  height: 50.0,
                  width: 50.0,
                  child: FittedBox(
                    child: FloatingActionButton(
                      child: Center(
                        child: Icon(Icons.refresh),
                      ),
                      onPressed: () async {
                        Flushbar(
                          flushbarPosition: FlushbarPosition.TOP,
                          title: "Accelerometer",
                          message: "Accelerometer Restarted",
                          duration: Duration(seconds: 2),
                        )..show(context);
                        setState(() {
                          stopwatch.stop();
                          stopwatch.reset();
                        });
                        await widget.storage.flushDocument();
                        isRunning = false;
                        accelerometerSubscription.cancel();
                        accelerometerSubscription = null;
                      },
                      backgroundColor: Colors.blue,
                      elevation: 10.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => {
          await FlutterEmailSender.send(_email),
          await widget.storage.flushDocument(),
        },
        tooltip: 'Share',
        child: Icon(Icons.share),
      ),
    );
  }
}
