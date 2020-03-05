import 'dart:io';
import 'dart:async';
import 'package:sensors/sensors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
    widget.storage.readCounter().then((int value) {
      setState(() {
        _counter = value;
      });
    });
  }

  @override
  void dispose() {
    accelerometerSubscription?.cancel();
    super.dispose();
  }

  Future<File> _incrementCounter() {
    setState(() {
      _counter++;
    });
    return widget.storage.writeCounter(_counter);
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
      print("userAccelerometerEvents");
      print(event);
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
            Text(
              'Button tapped $_counter time${_counter == 1 ? '' : 's'}.',
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
                        isRunning = true;
                        stopwatch.start();
                        const oneSec = const Duration(seconds: 1);
                        new Timer.periodic(
                            oneSec,
                            (Timer t) => {
                                  if (isRunning)
                                    {
                                      _useAccelerometer(),
                                      print(
                                          'Working!, ${accelerometerEvent.toString()}'),
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
                        stopwatch.stop();
                        print("${stopwatch.elapsedMilliseconds}");
                        accelerometerSubscription.pause();

                        isRunning = false;
                        accelerometerSubscription.cancel();
                        accelerometerSubscription = null;
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
                        stopwatch.stop();
                        stopwatch.reset();
                        print("${stopwatch.elapsedMilliseconds}");
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () async => await FlutterEmailSender.send(_email),
            tooltip: 'Share',
            child: Icon(Icons.share),
          ),
          SizedBox(
            height: 8.0,
          ),
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
