import 'dart:async';
import 'package:quiver/core.dart';

enum SpeakingState { startedTalking, stillTalking, stoppedTalking, notTalking }

class MyUsers {
  final int agoraID;
  final String name;
  final String fireID;

  bool isClientUser = false,
       showVolume = false,
       muted = false;
  Timer timer;
  double _speakOpacity = 0.1,
           volume = 50.0;
  int lastvolume = 0,
      cutOffVol = 5,
      averageVolume = 0,
      samples = 0,
      peakVolume = 0;

  MyUsers({this.fireID, this.agoraID, this.name});

  double get getVolume {
    return volume;
  }

  set setVolume(double vol) {
    volume = vol;
  }

  bool get getIsMuted {
    return muted;
  }

  void changeMuted() {
    print("Client is muted");
    muted = !muted;
  }

  set setisClientUser(bool _isClientUser) {
    isClientUser = _isClientUser;
  }

  bool get getIsClientUser {
    return isClientUser;
  }

  int get getAgoraID {
    return agoraID;
  }

  String get getName {
    return name;
  }

  double get getSpeakOpacity {
    return _speakOpacity;
  }

  bool get getShowVolume {
    return showVolume;
  }

  int get getAvgVolume {
    return averageVolume;
  }

  int get getPeakVolume {
    return peakVolume;
  }

  SpeakingState currentlySpeaking(int vol) {
    //last volume below cutoff & new volume above cutoff
    if (lastvolume < cutOffVol && vol > cutOffVol) {
      _speakOpacity = 0.9;
      averageVolume = vol;
      peakVolume = vol;
      lastvolume = vol;
      samples = 1;

      return SpeakingState.startedTalking;
    } else

    //Person is still speaking
    if (lastvolume > cutOffVol && vol > cutOffVol) {
      // print("still talking");
      samples++;
      averageVolume += vol;
      if (vol > peakVolume) peakVolume = vol;
        lastvolume = vol;

      return SpeakingState.stillTalking;
    } else 
    
    //person stopped talking. calculate average
    if (lastvolume > cutOffVol && vol < cutOffVol) {
      averageVolume = (averageVolume / samples).floor();
      _speakOpacity = 0.2;
      lastvolume = vol;

      return SpeakingState.stoppedTalking;
    } else 
   
    {
      _speakOpacity = 0.2;
      lastvolume = vol;
      
      return SpeakingState.notTalking;
    }
  }

  void changeVolume() {
    showVolume = !showVolume;
  }

  bool operator ==(o) =>
      o is MyUsers && fireID == o.fireID && agoraID == o.agoraID;
  int get hashCode => hash2(fireID, agoraID);
}
