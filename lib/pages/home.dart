import 'dart:async';
import 'dart:ui';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import './call.dart';
import '../services/database.dart';
import '../services/logger.dart';
import '../services/tokengen.dart';
import '../utils/settings.dart';
import '../widgets/questionnaire_widget.dart';
import '../services/auth.dart';
import './loading.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CallState();
}

class CallState extends State<Home> with WidgetsBindingObserver {
  final _auth = AuthService();
  TokenGen tokenGen = new TokenGen();
  TextEditingController nameChange = TextEditingController();
  Logger logger;
  DocumentSnapshot _user;
  bool showQuestionaireReminder = false;
  bool switchBool = false;
  DateTime lastChecked;
  bool _loading = true;
  bool _showLoader = true;

  // Future<void> _firebaseMessagingBackgroundHandler(
  //     RemoteMessage message) async {
  //   // If you're going to use other Firebase services in the background, such as Firestore,
  //   // make sure you call `initializeApp` before using other Firebase services.
  //   await Firebase.initializeApp();
  //   print("Handling a background message: ${message.messageId}");
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    //check dev privileges

    checkQuestionaire();
    // initFireMsg();
  }

  // void initFireMsg() async {
  //   await Firebase.initializeApp().then((value) =>
  //       FirebaseMessaging.onBackgroundMessage(
  //           _firebaseMessagingBackgroundHandler));
  // }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void checkQuestionaire() async {
    final prefs = await SharedPreferences.getInstance();
    String lastCallString = prefs.getString("lastCall");
    String lastQuestionnaireString = prefs.getString("lastQuestionnaire");

    DateTime lastCall =
        (lastCallString != null) ? DateTime.parse(lastCallString) : null;
    DateTime lastQuestionnaire = (lastQuestionnaireString != null)
        ? DateTime.parse(lastQuestionnaireString)
        : null;

    DateTime now = DateTime.now();

    if (lastCall != null) {
      if (lastQuestionnaire == null) {
        showQuestionaireReminder = true;
      } else {
        if (lastCall.day != lastQuestionnaire.day && lastCall.day == now.day) {
          showQuestionaireReminder = true;
        } else {
          showQuestionaireReminder = false;
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (_user != null) Logger().logAppResumed(_user.id);
    }

    if (state == AppLifecycleState.inactive) {
      if (_user != null) {
        Logger().logAppInactive(_user.id);
        Logger().uploadLocalLog();
      }
    }

    if (state == AppLifecycleState.detached) {
      if (_user != null) Logger().logAppClosed(_user.id);
    }
  }

  Widget devInterface(DocumentSnapshot userData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Divider(),
        Text(
          "Udvikler tilstand",
          style: TextStyle(fontSize: 20),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: ElevatedButton(
            onPressed: () {
              onReset(userData.get('agoraID'));
            },
            child: Text('Reset settings'),
          ),
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ElevatedButton(
              onPressed: signOut,
              child: Text('Sign out'),
            )),
      ],
    );
  }

  void _timer(DocumentSnapshot user) async {
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _showLoader = false;
        Logger().logAppOpened(user.id);
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<DocumentSnapshot>(context);
    double height = MediaQuery.of(context).size.height * 0.8;
    if (_showLoader) {
      if (userData != null) _loading = false;
      if (!_loading) _timer(userData);
      return Scaffold(body: LoadingSpinner(loading: _loading));
    } else {
      checkQuestionaire();
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: PopupMenuButton(
            icon: Icon(Icons.settings),
            offset: Offset(-100, -100),
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry>[
                PopupMenuItem(
                    //Change name
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      controller: nameChange,
                      decoration: InputDecoration(
                        hintText: 'Indtast nyt navn',
                      ),
                      onSubmitted: (String value) async {
                        if (nameChange.text.isNotEmpty) {
                          await DatabaseService(uid: userData.id)
                              .updateUsername(nameChange.text);
                          nameChange.clear();
                        }
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameChange.text.isNotEmpty) {
                          await DatabaseService(uid: userData.id)
                              .updateUsername(nameChange.text);
                          nameChange.clear();
                        }
                      },
                      child: Text('Skift navn'),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                )),
                PopupMenuItem(
                    //Contact developers
                    child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Row(
                      children: [
                        Text("Darkmode "),
                        Switch(
                            value: switchBool,
                            onChanged: (value) {
                              setState(() {
                                switchBool = value;
                              });

                              value
                                  ? AdaptiveTheme.of(context).setDark()
                                  : AdaptiveTheme.of(context).setLight();
                            })
                      ],
                    );
                  },
                )),
                PopupMenuItem(
                  //Contact developers
                  child: ElevatedButton(
                    onPressed: () async {
                      String url =
                          'mailto:<hci1016f21@cs.aau.dk>?subject=Respons fra ${userData.get('name')}&body=Beskriv dit problem eller spørgsmål!';
                      return await canLaunch(url)
                          ? await launch(url)
                          : throw 'Could not send mail $url';
                    },
                    child: Text('Kontakt på mail'),
                  ),
                ),
                
              ];
            },
          ),
          title: Text('Velkommen ${userData.get('name')}'),
        ),
        body: Center(
          heightFactor: 1,
          child: Column(
            children: [
              Stack(
                children: [
                  if (showQuestionaireReminder)
                    Card(
                      // CARD NOTIFICATION
                      margin:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: openQuestionnaire,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Icon(Icons.calendar_today),
                                    ),
                                    Text(
                                      'Påmindelse',
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10.0, bottom: 5),
                                child: Text(
                                  'Husk at udfylde spørgeskemaet inden kl: 23:59.',
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Divider(color: Colors.white),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    'Tryk her for at besvare spørgeskemaet',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        margin: EdgeInsets.only(top: 40),
                        height: height,
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: ElevatedButton(
                                onPressed: () => {
                                  DatabaseService(uid: userData.id)
                                      .updateInCall(true),
                                  startCall(
                                      agoraID: userData.get('agoraID'),
                                      name: userData.get('name'))
                                },
                                child: Text(
                                  'Start opkald',
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  minimumSize: Size.fromRadius(80),
                                ),
                              ),
                            ),
                            if (userData.get('devMode') || Dev)
                              devInterface(userData),
                          ],
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  void openQuestionnaire() async {
     await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => (QuestionnaireWidget(
          fireID: _auth.getCurrentUser(),
        )),
      ),
    ).then((value) => {
          setState(() {
            checkQuestionaire();
          })
        });
  }

  Future<void> startCall({int agoraID, String name}) async {
    print("AgoraID $agoraID");
    String fireID = _auth.getCurrentUser();
    String token = await TokenGen(agorauid: agoraID).requestToken();
    Logger().logJoinedCall(fireID);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => (CallPage(
          name: name,
          token: token,
          fireID: fireID,
          agoraID: agoraID,
        )),
      ),
    ).then((value) => {
          setState(() {
            checkQuestionaire();
          })
        });
  }

  void signOut() {
    _auth.signOut(_auth.getCurrentUser());
  }

  void onReset(int agoraid) async {
    TokenGen(agorauid: agoraid).requestToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void onClearFirebase() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.remove("lastQuestionnaire");
      prefs.remove("lastCall");
    });

  }
}
