import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth.dart';

class IntroPage3 extends StatefulWidget {
  final name;
  IntroPage3({this.name});
  @override
  IntroPageState createState() => IntroPageState();
}

class IntroPageState extends State<IntroPage3> {
  bool _checkedValue = false;
  bool _checkError = false;
  @override
  Widget build(BuildContext context) {
    print(widget.name);
    return Scaffold(
      backgroundColor: Color(0xFF7FA4EF),
      bottomNavigationBar: bottomBar(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Vi er næsten klar til at begynde!",
                  style: TextStyle(fontSize: 26, color: Colors.white)),
              Divider(),
              Text(
                "Denne app benyttes som en del af et universitets projekt og der vil derfor indsamles data som brugsmønstre og personlige informationer. \n\nFx: Alder, køn, hvornår appen bruges, hvor længe den bruges og lokation  \n\nVi optager ikke samtalerne!",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Divider(),
              CheckboxListTile(
                title: Text(
                    "Jeg er indforstået med at mine informationer vil blive indsamlet og benyttes anonymt til forskning på Aalborg universitet",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    )),
                subtitle: (_checkError)
                    ? Text(
                        "Checkboxen skal udfyldes før appen kan benyttes",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      )
                    : null,
                value: _checkedValue,
                onChanged: (newValue) {
                  setState(() {
                    _checkedValue = newValue;
                  });
                },

                controlAffinity:
                    ListTileControlAffinity.leading, //  <-- leading Checkbox
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomBar() {
    return BottomAppBar(
        color: Color(0xFF7395D9),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: Container(
              //color: Colors.yellow,
              height: 10,
            )),
            Container(
              // color: Colors.green,
              width: 120.0,
              height: 56,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white60),
                    ),
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white60),
                    ),
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                    ),
                  ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  height: 40,
                  //   color: Colors.red,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      side: BorderSide(
                        width: 1,
                        color: Color(0x22CCCCCC),
                      ),
                    ),
                    onPressed: _next,
                    child: Text(
                      'Færdig',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Future<bool> _doPermissions() async {
    PermissionStatus microphone = await Permission.microphone.request();
    PermissionStatus location = await Permission.location.request();
    if (microphone.isGranted && location.isGranted) return true;

    return false;
  }

  void saveIntroDone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("IntroComplete", true);
  }

  AuthService _auth = AuthService();
  void _next() async {
    if (_checkedValue) {
      _doPermissions().then((permission) => {
            if (permission) {
                saveIntroDone(),
                _auth.signInAnon(widget.name),
                Navigator.popUntil(context, (route) => route.isFirst),
              }
          });
    } else {
      setState(() {
        _checkError = true;
      });
    }
  }
}
