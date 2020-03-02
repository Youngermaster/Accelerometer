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
  double _accelerometerX;
  double _accelerometerY;
  double _accelerometerZ;

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

  Future<File> _incrementCounter() {
    setState(() {
      _counter++;
    });
    return widget.storage.writeCounter(_counter);
  }

  void _useAccelerometer() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      print("accelerometerEvents");
      _accelerometerX = event.x;
      _accelerometerY = event.y;
      _accelerometerZ = event.z;
      print(event);
    });
  }

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
            Container(
              height: 200.0,
              width: 200.0,
              child: FittedBox(
                child: FloatingActionButton(
                  child: Center(
                    child: Text("Start"),
                  ),
                  onPressed: () async {
                    print("F");
                    stopwatch.start();
                    // await FlutterEmailSender.send(_email);
                  },
                  backgroundColor: Colors.red,
                  elevation: 0,
                ),
              ),
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
                        stopwatch.start();
                      },
                      backgroundColor: Colors.green,
                      elevation: 0,
                    ),
                  ),
                ),
                Container(
                  height: 50.0,
                  width: 50.0,
                  child: FittedBox(
                    child: FloatingActionButton(
                      child: Center(
                        child: Icon(Icons.stop),
                      ),
                      onPressed: () async {
                        stopwatch.stop();
                        print("${stopwatch.elapsedMilliseconds}");
                      },
                      backgroundColor: Colors.red,
                      elevation: 0,
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
                      },
                      backgroundColor: Colors.blue,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
