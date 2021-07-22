import 'package:cloud_firestore/cloud_firestore.dart';
import './filewriter.dart';
import 'package:geolocator/geolocator.dart';

//pair enum values with data analysis tool after data collection
enum EventType {
  appOpen,    //0
  appClosed,  //1
  appInactive,//2
  appResumed, //3
  userTalked, //4
  userMuted,  //5
  joinCall,   //6
  leftCall,   //7
  questionnaire, //8
  questionnaireSkipped, //9
}

class Logger {

  //todo: Make class functionality static

  final CollectionReference log = FirebaseFirestore.instance.collection('logs');
  
  final FileWriter fw = FileWriter();

  // Determine the current position of the device.
  //
  // When the location services are not enabled or permissions
  // are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
  //Constructs a log entry
  Map<String, dynamic> constructLog(
      EventType eventtype, String id, Timestamp timestamp, [Map<String, dynamic> options]) {

    Map<String, dynamic> package = {
      'id': id,
      'timestamp': timestamp,
      'event': eventtype.index,
    };
    //append options to package, if it is not empty
    if (options != null) package.addAll(options);

    return package;
  }

  //upload the local log to firebase and clear it afterwards.
  void uploadLocalLog() async {
    print("uploading local log");
    bool error = false;
    List<Map<String, dynamic>> localLogs = await fw.parseLogs();
    if (localLogs != null) {
      localLogs.forEach((localLog) async {
        DocumentReference result = await log.add(localLog);
        if (result.id.isEmpty) {
          print("Error uploading ${localLog.toString()}");
          error = true;
        }
      });
    } else
      error = true;
    print("error in upload: $error");
    if (!error) await fw.clearLog();
  }

  //log when the user opens the app
  Future<DocumentReference> logAppOpened(String id) async {
    try {
      Position pos = await _determinePosition();
      return await log.add(constructLog(EventType.appOpen, id, Timestamp.now(),
          {'lat': pos.latitude, 'long': pos.longitude}));
    } catch (error) {
      print(error);
      return await log.add(constructLog(
          EventType.appOpen, id, Timestamp.now(), {'location': '0'}));
    }
  }
  
  //In the rare chance the system actually logs it was closed, log it.
  //otherwise we rely on the inactive/resumed states to figure out if the user closed the app.
  Future<DocumentReference> logAppClosed(String id) async {
    try {
      Position pos = await _determinePosition();
      return await log.add(constructLog(EventType.appClosed, id,
          Timestamp.now(), {'lat': pos.latitude, 'long': pos.longitude}));
    } catch (error) {
      print(error);
      return await log.add(constructLog(
          EventType.appClosed, id, Timestamp.now(), {'location': 0}));
    }
  }

//Log when the user left the app
  //this is used to determine if they left the app/closed it
  Future<DocumentReference> logAppInactive(String id) async {
    return await log
        .add(constructLog(EventType.appInactive, id, Timestamp.now()));
  }
  //Log when the user returns to the app
  //this is used to determine if they left the app/closed it
  Future<DocumentReference> logAppResumed(String id) async {
    return await log
        .add(constructLog(EventType.appResumed, id, Timestamp.now()));
  }

  //Log when user talks, many entries, so log this in a local storage
  //and upload to firebase later
  void writeUserTalked(String id, [Map<String, dynamic> options]) async {
    print("write user talked");
    Map<String, dynamic> log =
        constructLog(EventType.userTalked, id, Timestamp.now(), options);

      await fw.writeLog(log);
  }

  //Log when the user mutes themselves
  Future<DocumentReference> logUserMuted(String id, bool muted) async {
    return await log.add(constructLog(
        EventType.userMuted, id, Timestamp.now(), {'muted': muted}));
  }

  //log when a user joins the voice chat
  Future<DocumentReference> logJoinedCall(String id) async {
    try {
      Position pos = await _determinePosition();
      return await log.add(constructLog(EventType.joinCall, id, Timestamp.now(),
          {'lat': pos.latitude, 'long': pos.longitude}));
    } catch (error) {
      print(error);
      return await log.add(constructLog(
          EventType.joinCall, id, Timestamp.now(), {'location': 0}));
    }
  }

  //log when a user leaves the voice chat
  Future<DocumentReference> logLeftCall(String id) async {
    try {
      Position pos = await _determinePosition();
      return await log.add(constructLog(EventType.leftCall, id, Timestamp.now(),
          {'lat': pos.latitude, 'long': pos.longitude}));
    } catch (error) {
      print(error);
      return await log.add(constructLog(EventType.leftCall, id, Timestamp.now(),
          {'location': await _determinePosition()}));
    }
  }

  //log data from complted questionnaire
  Future<DocumentReference> logQuestionnaire(
      String id, Map<String, dynamic> questions) async {
    return await log.add(
        constructLog(EventType.questionnaire, id, Timestamp.now(), questions));
  }

  //log when the user decides to skip filling the questionnaire.
  Future<DocumentReference> logQuestionnaireSkip(String id) async {
    return await log
        .add(constructLog(EventType.questionnaireSkipped, id, Timestamp.now()));
  }
}
