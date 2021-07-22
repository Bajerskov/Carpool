import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PermissionState();
}

class PermissionState extends State<PermissionPage> {
  @override
  void initState() async {
    super.initState();
    await _checkPermission().then((permission) => {
          if (permission)
            {Navigator.popUntil(context, (route) => route.isFirst)}
        });
  }

  Future<bool> _checkPermission() async {
    PermissionStatus microphone = await Permission.microphone.request();
    PermissionStatus location = await Permission.location.request();
    return (microphone.isGranted && location.isGranted) ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF466D1D),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Vi har brug for din tilladelse!",
                  style: TextStyle(fontSize: 26, color: Colors.white)),
              Divider(),
              Text(
                  "For at kunne benytte appen har vi brug for at du tillader appen at benytte mikrofon og lokation!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  )),
              Divider(),
              Text("Hvorfor skal vi bruge tiladelse til mikrofon?",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text(
                  "For at kunne tale med de andre i gruppen har vi brug for tilladelse til at benytte mikrofonen. Vi optager ikke lyd og bruger kun mikrofonen når du starter opkaldet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  )),
              Divider(),
              Text("Hvorfor skal vi bruge tilladelse til lokation?",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text(
                  "For at få bedre indsigt i hvordan og hvornår appen benyttes har vi behov for lokation til at vurdere hvilken effekt afstand og hvor appen benyttes, har på resultaterne ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  )),
              Visibility(
                visible: _stillNotGranted,
                child: Text(
                  "Tilladelser er stadig ikke givet, prøv igen.",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  side: BorderSide(
                    width: 1,
                    color: Color(0x22CCCCCC),
                  ),
                ),
                onPressed: getPermissions,
                child: Text(
                  'NÆSTE',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _stillNotGranted = false;

  void getPermissions() async {
    _checkPermission();
    if (await openAppSettings()) {
      bool mic = await Permission.microphone.isGranted;
      bool loc = await Permission.location.isGranted;
      if (mic && loc) {
        Navigator.pop(context);
      } else {
        setState(() {
          _stillNotGranted = true;
        });
      }
    }
  }

  void goBack() async {
    Navigator.pop(context);
  }
}
