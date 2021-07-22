import 'dart:async';
import 'package:wakelock/wakelock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/voiceindication_widget_cards.dart';
import '../utils/settings.dart';
import '../models/user.dart';
import '../services/database.dart';
import '../services/logger.dart';
import '../widgets/questionnaire_widget.dart';

class CallWidget extends StatefulWidget {
  /// name of participant
  final String name;

  //Agora auth token
  final String token;

  //agora uid
  final int agoraID;

  ///Firebase UID
  final String fireID;

  /// Creates a call page with given channel name.
  const CallWidget({Key key, this.name, this.fireID, this.token, this.agoraID})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => CallWidgetState();
}

class CallWidgetState extends State<CallWidget> {
  //UI variable
  double _audioSliderValue;
  bool muted = false, changeAudio = false;
  Timer timer;
  static const platform = const MethodChannel('samples.flutter.dev/bluetooth');
 MyUsers clientRef = MyUsers();
  List<MyUsers> myUsers = <MyUsers>[];
  RtcEngine _engine;
  final Logger _log = Logger();
  SharedPreferences prefs;

  @override
  void dispose() {
    // clear users
    DatabaseService(uid: widget.fireID).updateInCall(false);
    disposeTimers();

    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    Wakelock.disable();
    myUsers.clear();
    super.dispose();
  }

  @override
  void initState() {
    Wakelock.enable();
    initialize();
    super.initState();
  }

  Future<void> initialize() async {
    myUsers.clear();

    prefs = await SharedPreferences.getInstance();
    prefs.containsKey("clientVolume")
        ? _audioSliderValue = prefs.getDouble("clientVolume")
        : _audioSliderValue = 60;

    try {
      await platform.invokeMethod('bluetooth');
    } on PlatformException catch (e) {
      print("failed to connect to bluetooth + $e");
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();

    await _engine.joinChannel(widget.token, Channel, null, widget.agoraID);
    await _engine.enableAudioVolumeIndication(200, 3, true);
    await _engine.setAudioProfile(
        AudioProfile.MusicStandard, AudioScenario.ChatRoomEntertainment);
  }

  void disposeTimers() {
    myUsers.forEach((_user) {
      _user.timer = null;
    });
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.disableVideo();
    await _engine.setChannelProfile(ChannelProfile.Communication);
    // await _engine.setClientRole(ClientRole.Broadcaster);
    _log.logJoinedCall(widget.fireID);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      print("Error: $code");
    }, leaveChannel: (stats) {
      DatabaseService(uid: widget.fireID).updateInCall(false);
      myUsers.clear();
    }, userOffline: (uid, elapsed) {
      setState(() {
        myUsers.removeWhere((element) => element.agoraID == uid);
      });
    }, audioVolumeIndication: (List<AudioVolumeInfo> speakers, int volume) {
      handleAudioIndication(speakers);
    }));
  }

  void handleAudioIndication(List<AudioVolumeInfo> speakers) {
    speakers.forEach((speaker) {
      myUsers.forEach((user) {
        if (speaker.volume >= 5) {
          if (speaker.uid == user.agoraID ||
              (speaker.uid == 0 && user.isClientUser)) {
            //reset timer if it is set, and set a new timer. When timer runs out,
            //log the users average volume, and peak volume.
            if (user.timer != null && user.timer.isActive) user.timer.cancel();
            user.timer = new Timer(Duration(seconds: 1), () {
              if (user.isClientUser)
                _log.writeUserTalked(widget.fireID,
                    {'avg': user.getAvgVolume, 'peak': user.getPeakVolume});
              if (this.mounted)
                setState(() {
                  user.currentlySpeaking(0);
                });
            });
          }
        }
      });
    });
    audioStreamController.add(myUsers);
  }

  StreamController<List<MyUsers>> audioStreamController =
      StreamController<List<MyUsers>>();

//wrap list of users as a stream to render list of users in call.
  Widget _userStream() {
    return StreamProvider<List<MyUsers>>.value(
        value: audioStreamController.stream,
        child: new VoiceIndicatorWidget(_engine, this));
  }

  /// Layout for change audio, hang call and mute self. 
  Widget _toolbar() {
    return Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: changeAudio,
              child: Row(
                children: <Widget>[
                  Slider(
                      value: _audioSliderValue,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: _audioSliderValue.round().toString(),
                      onChanged: _adjustMicSensitivity)
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: _onToggleAudioSlide,
                  child: Icon(
                    Icons.volume_up,
                    color: changeAudio ? Colors.white : Colors.blueAccent,
                    size: 20.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: changeAudio ? Colors.blueAccent : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
                RawMaterialButton(
                  onPressed: () => _onCallEnd(context),
                  child: Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 35.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.redAccent,
                  padding: const EdgeInsets.all(15.0),
                ),
                RawMaterialButton(
                  onPressed: () => {
                    setState(() {
                      int index = myUsers.indexWhere(
                          (element) => element.isClientUser == true);
                      myUsers[index].changeMuted();
                      _engine.muteLocalAudioStream(myUsers[index].getIsMuted);
                    }),
                  },
                  child: Icon(
                    clientRef.getIsMuted ? Icons.mic_off : Icons.mic,
                    color:
                        clientRef.getIsMuted ? Colors.white : Colors.blueAccent,
                    size: 20.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor:
                      clientRef.getIsMuted ? Colors.blueAccent : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
              ],
            ),
          ],
        ));
  }

  void _onToggleAudioSlide() {
    setState(() {
      changeAudio = !changeAudio;
    });
  }

  void _adjustMicSensitivity(double vol) {
    setState(() {
      _audioSliderValue = vol;
    });
    _engine.adjustRecordingSignalVolume(vol.toInt() * 4);
  }

  void _onCallEnd(BuildContext context) async {
    //log action.
    _log.logLeftCall(widget.fireID);
    _log.uploadLocalLog();
    _engine.leaveChannel();
    Wakelock.disable();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("lastCall", DateTime.now().toString());
    await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => QuestionnaireWidget(fireID: widget.fireID)));
  }

 
  //Todo: replace convoluted function with HashSet and class equality
  void insertUsers(QueryDocumentSnapshot usr) {
    //check wheter object containts both AgoraId and name, or we cant use it.
    if (usr.data().keys.contains("agoraID") &&
        usr.data().keys.contains("name") &&
        usr.get('inCall') == true) {
      //Create tmp object to check against other list.
      int auid = usr.get('agoraID');
      String fireId = usr.id;
      String name = usr.get('name');
      MyUsers tmpUsr = new MyUsers(fireID: fireId, agoraID: auid, name: name);

      //if current user in list is the client, set isclientUser to true
      if (fireId == widget.fireID) {
        tmpUsr.setisClientUser = true;
      }

      //Does the list already contain the user
      if (myUsers.indexWhere((element) => element.agoraID == usr.get('agoraID')) == -1) {
        myUsers.add(tmpUsr);

        if (tmpUsr.isClientUser) 
          clientRef = myUsers.last;
        
      } else {
        if (Dev) print('List already contains: ' + usr.get('name'));
      }
    } else if (usr.data().containsKey('inCall')) {
      if (usr.get('inCall') == false) {
        if (Dev) print('Removing: ' + usr.get('name'));
        myUsers.removeWhere((element) => element.agoraID == usr.get('agoraID'));
      }
    }
  }

  //Sidste snapshot, så vi kan sammenligne med det nye for at se om der er en forskel
  QuerySnapshot oldsnapshot;
  @override
  Widget build(BuildContext context) {
    if (Dev) print("re-building Call-widget");

    //Få det nye snapshot fra firebase
    final snapshot = Provider.of<QuerySnapshot>(context);
    //Er det gamle og nye snapshot ens? Interfacet rebuilder når man interagere med det.
    //ingen grund til at rebuilde det hele, hvis der ikke er noget nyt data.
    if (snapshot != oldsnapshot) {
      if (Dev) print("New snapshot!");
      //hvis de er forskellige, iterere vi over den nye liste i insertUsers
      snapshot.docs.map((e) => insertUsers(e));

      //assign det nye snapshot til det gamle
      oldsnapshot = snapshot;
    }

    return Stack(
      children: [
        _userStream(),
        _toolbar(),
      ],
    );
  }
}
