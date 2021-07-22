import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future createUser(String name, int agoraID) async {
    userCollection.get().then((collection) async {
      return await userCollection.doc(uid).set({
        'name': name,
        'agoraID': agoraID,
        'inCall': false,
             'devMode': false,
      });
    });
  }

  Future updateUsername(String name) async {
    print('Change name: $name');
    return await userCollection.doc(uid).update({
      'name': name,
    });
  }

  Future updateInCall(bool inCall) async {
    return await userCollection.doc(uid).update({'inCall': inCall});
  }

  Future deleteUser() async {
    return await userCollection.doc(uid).delete();
  }


  Stream<DocumentSnapshot> get userData {
    return userCollection.doc(uid).snapshots();
  }

  Stream<QuerySnapshot> get users {
    return userCollection.snapshots();
  }

  Future clearCollection() async {
    return await userCollection.get().then((snapshot) => {
          for (DocumentSnapshot ds in snapshot.docs)
            {print("Deleting ${ds.data().toString()}"), ds.reference.delete()}
        });
  }
}
