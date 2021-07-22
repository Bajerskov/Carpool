import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database.dart';
import '../widgets/call_widget.dart';

class CallPage extends StatefulWidget {
  /// name of participant
  final String name;

  //Agora auth token
  final String token;

  //agora uid
  final int agoraID;

  ///Firebase UID
  final String fireID;

  /// Creates a call page with given channel name.
  const CallPage({Key key, this.name, this.token, this.fireID, this.agoraID})
      : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

//gets firebase stream and wraps the widget `CallWidget` in the stream
//The child component will be rebuilt every time there is an update in the stream.
class _CallPageState extends State<CallPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('I opkald med: '),
      ),
      body: Center(
          child: StreamProvider<QuerySnapshot>.value(
        value: DatabaseService().users,
        child: Container(
          child: CallWidget(
            name: widget.name,
            token: widget.token,
            fireID: widget.fireID,
            agoraID: widget.agoraID,
          ),
        ),
      )),
    );
  }
}
