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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.red),
        ),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Elapsed time',
                  style: TextStyle(fontSize: 35.0, color: Colors.white),
                ),
                Text(
                  'Seconds: ${stopwatch.elapsedMilliseconds ~/ 1000}',
                  style: TextStyle(fontSize: 15.0, color: Colors.white),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Text(
                  "Periodicity",
                  style: TextStyle(fontSize: 35.0, color: Colors.white),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        "$peridiocity milliseconds",
                        style: TextStyle(fontSize: 15.0, color: Colors.white),
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
                          "Change",
                          style: TextStyle(fontSize: 15.0, color: Colors.white),
                        ),
                      )
                    ]),
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
                ),
              ],
            ),
          ],
        ),
      ),
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
}
