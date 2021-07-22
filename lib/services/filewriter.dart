import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileWriter {
  Future<String> get _localPath async {
    try {
      //Android and IOS use different directives to interact with file system.
      Directory directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationSupportDirectory();
      if (await directory.exists())
        return directory.path;
      else
        return null;
    } catch (error) {
      print(error);
      return error;
    }
  }

  //returns the file object from the path
  Future<File> get _localFile async {
    final path = await _localPath;
    //if the path is null return null
    if (_localPath == null) return null;
    //assign local file object to test if it exists
    return File('$path/voice.txt');
  }

  //clears the log file
  Future clearLog() async {
    final file = await _localFile;
    if (!await file.exists()) return null;
    print("Deleting log");

    await file.delete();
  }

  //write a json object to the local file.
  Future<File> writeLog(Map<String, dynamic> log) async {
    final file = await _localFile;
    String json = jsonEncode(toJson(log));
    return file.writeAsString(json + "---", mode: FileMode.append);
  }

//Prepare the map object to be encoded to json.
//Firebase timestamp format isn't json friendly, convert it to Epoch string.
  Map<String, dynamic> toJson(Map<String, dynamic> input) {
    Map<String, dynamic> temp = {};
    input.forEach((key, value) {
      if (value is Timestamp)
        temp.addAll({key: value.toDate().toIso8601String()});
      else
        temp.addAll({key: value});
    });
    return temp;
  }

  //parse input map to json and write to local file. 
  Future<List<Map<String, dynamic>>> parseLogs() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        print("File exists");
        // Read the file.
        String contents = await file.readAsString();
        //Splits strings based on known devisor
        List<String> logStrings = contents.split("---");
        List<Map<String, dynamic>> results = [];

        //parsing each json string and converts to map
        logStrings.forEach((element) {
          if (element.isNotEmpty) {
            //Creating a temporary map and assigning it the value of a jsonDecode.
            //jsondecode uses a reviver function to "revive" strings back to original objects.
            Map<String, dynamic> tempMap = jsonDecode(element,
                reviver: (key, value) => jsonReviver(key, value));

            //Add temporary map to results
            results.add(tempMap);
          }
        });
        //Return results
        return results;
      }
      print("File doesn't exist");
      return null;
    } catch (e) {
      // If encountering an error, return 0.
      print(e);
      return null;
    }
  }

  /// Checks if key is [timestamp, begin, end] and returns a timestamp object.
  dynamic jsonReviver(String key, dynamic value) {
    if (key == "timestamp" || key == "begin" || key == "end") {
      return Timestamp.fromDate(DateTime.parse(value));
    }
    return value;
  }
}
