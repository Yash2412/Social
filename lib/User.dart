import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  String displayName;
  DateTime creationTime;
  DateTime lastSignInTime;
  String phoneNumber;
  String photoURL;
  String uid;

  UserService(
      {this.displayName,
      this.creationTime,
      this.lastSignInTime,
      this.phoneNumber,
      this.photoURL,
      this.uid});

  void addUser() {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    users.doc((this.uid)).set({
      "displayName": this.displayName,
      "creationTime": this.creationTime,
      "lastSignInTime": this.lastSignInTime,
      "phoneNumber": this.phoneNumber,
      "photoURL": this.photoURL,
      "uid": this.uid,
    }).then((value) => print('user added'));
  }

  void addChat(contact, conversation) {
    DateTime dt = new DateTime.now();
    String myUID = FirebaseAuth.instance.currentUser.uid;
    String hisUID = contact['uid'];

    FirebaseFirestore.instance
        .collection('users')
        .doc(myUID)
        .collection(hisUID)
        .add({'msg': conversation, 'sendByMe': true, 'sendAt': dt}).then(
            (value) => print('MY chat added'));

    FirebaseFirestore.instance
        .collection('users')
        .doc(hisUID)
        .collection(myUID)
        .add({'msg': conversation, 'sendByMe': false, 'sendAt': dt}).then(
            (value) => print('his chat added'));

    FirebaseFirestore.instance
        .collection('users')
        .doc(myUID)
        .collection('RecentChats')
        .doc(hisUID)
        .set({
      'lastMsg': conversation,
      'sendByMe': true,
      'lastSignInTime': contact['lastSignInTime'],
      'displayName': contact['displayName'],
      'sendAt': dt,
      'uid': contact['uid'],
      'phoneNumber': contact['phoneNumber'],
      'photoURL': contact['photoURL']
    }).then((value) => print('My Recent chat added'));

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore.instance
        .collection('users')
        .doc(hisUID)
        .collection('RecentChats')
        .doc(myUID)
        .set({
      'lastMsg': conversation,
      'sendByMe': false,
      'lastSignInTime': auth.currentUser.metadata.lastSignInTime,
      'displayName': auth.currentUser.displayName,
      'sendAt': dt,
      'uid': auth.currentUser.uid,
      'phoneNumber': auth.currentUser.phoneNumber,
      'photoURL': auth.currentUser.photoURL
    }).then((value) => print('his Recent chat added'));
  }
}
