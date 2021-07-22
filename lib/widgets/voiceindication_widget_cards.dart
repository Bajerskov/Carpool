import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'call_widget.dart';

class VoiceIndicatorWidget extends StatefulWidget {
  final RtcEngine engine;
  final CallWidgetState parent;
  VoiceIndicatorWidget(this.engine, this.parent);

  @override
  State<StatefulWidget> createState() => VoiceIndicatorWidgetState();
}

class VoiceIndicatorWidgetState extends State<VoiceIndicatorWidget> {
  SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    initialise();
  }

  void initialise() async {
    prefs = await SharedPreferences.getInstance();
  }

  double returnUserVol(MyUsers user) {
    double vol;
    //individual preferences to other useres volume is stored based on their unique firebase id.
    if (prefs.containsKey(user.fireID)) {
      vol = prefs.getDouble(user.fireID);
    } else {
      vol = 60;
    }
    user.setVolume = vol;
    widget.engine.adjustUserPlaybackSignalVolume(user.agoraID, vol.toInt());

    return vol;
  }

  void setUserVol(MyUsers user, double vol) {
    setState(() {
      user.setVolume = vol;
      widget.engine.adjustUserPlaybackSignalVolume(user.agoraID, vol.toInt());
    });

    prefs.setDouble(user.fireID, vol);
  }

  @override
  Widget build(BuildContext context) {
    List<MyUsers> myUsers = Provider.of<List<MyUsers>>(context);
    if (myUsers != null)
      return ListView.builder(
          itemCount: myUsers.length,
          itemBuilder: (BuildContext context, int index) {
            if (myUsers.isEmpty) {
              return null;
            }

            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: 40,
                            width: 40,
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.grey[500]
                                  .withOpacity(myUsers[index].getSpeakOpacity),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 2,
                                  color: Colors.blueAccent.withOpacity(
                                      myUsers[index].getSpeakOpacity)),
                            ),
                          ),
                          Visibility(
                            visible: !myUsers[index].showVolume,
                            child: Text(myUsers[index].getName,
                                style: Theme.of(context).textTheme.headline6),
                          ),
                          Visibility(
                            visible: myUsers[index].showVolume,
                            child: Slider(
                              value: returnUserVol(myUsers[index]),
                              min: 0,
                              max: 100,
                              divisions: 100,
                              label: myUsers[index].volume.round().toString(),
                              onChanged: (double value) {
                                setUserVol(myUsers[index], value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    //audio visualiser
                    if (!myUsers[index].getIsClientUser)
                      Container(
                        alignment: Alignment.centerRight,
                        child: RawMaterialButton(
                          onPressed: () => {
                            setState(() {
                              myUsers[index].changeVolume();
                            })
                          },
                          child: Icon(
                            Icons.volume_up,
                            color: myUsers[index].showVolume
                                ? Colors.white
                                : Colors.blueAccent,
                            size: 20.0,
                          ),
                          shape: CircleBorder(),
                          elevation: 2.0,
                          fillColor: myUsers[index].showVolume
                              ? Colors.blueAccent
                              : Colors.white,
                          padding: const EdgeInsets.all(12.0),
                        ),
                      ),
                    if (myUsers[index].getIsClientUser)
                      Container(
                        alignment: Alignment.centerRight,
                        child: RawMaterialButton(
                          onPressed: () => {
                            widget.parent.setState(() {
                              myUsers[index].changeMuted();
                              widget.engine.muteLocalAudioStream(
                                  myUsers[index].getIsMuted);
                            }),
                          },
                          child: Icon(
                            myUsers[index].getIsMuted
                                ? Icons.mic_off
                                : Icons.mic,
                            color: myUsers[index].muted
                                ? Colors.white
                                : Colors.blueAccent,
                            size: 20.0,
                          ),
                          shape: CircleBorder(),
                          elevation: 2.0,
                          fillColor: myUsers[index].getIsMuted
                              ? Colors.blueAccent
                              : Colors.white,
                          padding: const EdgeInsets.all(12.0),
                        ),
                      ),
                  ],
                ),
              ),
            );
          });
    else
      return Container();
  }
}
