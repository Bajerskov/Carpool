import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //create user
  MyUsers _myUsers({User user, String name, int agoraID}) {
    return (user != null)
        ? MyUsers(fireID: user.uid, agoraID: agoraID, name: name)
        : null;
  }

  String getCurrentUser() {
    return _auth.currentUser.uid;
  }

  //user status change
  Stream<MyUsers> get user {
    return _auth.authStateChanges().map((User user) => _myUsers(user: user));
  }

  //sign in anon
  Future signInAnon(String name) async {
    final int agoraID = new Timestamp.now().nanoseconds;
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user;
      await DatabaseService(uid: user.uid).createUser(name, agoraID);
      return _myUsers(user: user, name: name, agoraID: agoraID);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut(String uid) async {
    try {
      print('Delete user: ${_auth.currentUser}');
      _auth.currentUser.delete();
      await DatabaseService(uid: uid).deleteUser();
    } catch (e) {
      print(e.toString());
    }
  }

  clearData() {
    _auth.signOut();
  }
}
