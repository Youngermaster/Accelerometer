import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Storage {
  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.txt');
  }

  Future<int> readAccelerometer() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return int.parse(contents);
    } catch (e) {
      return 0;
    }
  }

  Future<File> writeAccelerometer(String counter) async {
    final file = await _localFile;
    return file.writeAsString(counter, mode: FileMode.append);
  }

  
  Future<File> flushDocument() async {
    final file = await _localFile;
    return file.writeAsString("", mode: FileMode.write, flush: true);
  }
}