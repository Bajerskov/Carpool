import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './pages/introPage1.dart';
import './pages/permissionPage.dart';
import './services/database.dart';
import './models/user.dart';
import 'pages/home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  //check if user exists
    final user = Provider.of<MyUsers>(context);
    if (user == null) {
      //if not go through intro flow.
      return IntroPage1();
    } else {
      //if user does exist, check if we have completed intro flow and have 
      // the right permissions to continue. 
      introCheck().then((boolean) => {
            if (boolean) {permissionCheck(context)}
          });

      return StreamProvider<DocumentSnapshot>.value(
        value: DatabaseService(uid: user.fireID).userData,
        child: Home(),
      );
    }
  }

  Future<bool> introCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("introComplete")) {
      return prefs.getBool("introComplete");
    } else {
      //intro not complete
      return false;
    }
  }

  void permissionCheck(BuildContext context) async {
    bool microphone = await Permission.microphone.isGranted;
    bool location = await Permission.location.isGranted;

    if (microphone && location) {
      return;
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PermissionPage()));
    }
  }
}
