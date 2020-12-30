import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class UserService {
  String displayName;
  DateTime creationTime;
  DateTime lastSignInTime;
  String phoneNumber;
  String pushNotificationToken;
  String photoURL;
  String uid;

  UserService(
      {this.displayName,
      this.creationTime,
      this.lastSignInTime,
      this.phoneNumber,
      this.pushNotificationToken,
      this.photoURL,
      this.uid});

  void addUser() {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    users.doc((this.uid)).set({
      "displayName": this.displayName,
      "creationTime": this.creationTime,
      "lastSignInTime": this.lastSignInTime,
      "lastSceen": DateTime.now(),
      "phoneNumber": this.phoneNumber,
      "photoURL": this.photoURL,
      "isTyping": false,
      "isOnline": true,
      "pushNotificationToken": this.pushNotificationToken,
      "uid": this.uid,
    }).then((value) => print('user added'));
  }

  void addChat(contact, conversation) async {
    DateTime dt = new DateTime.now();
    String myUID = FirebaseAuth.instance.currentUser.uid;
    String hisUID = contact['uid'];
    String token = await FirebaseMessaging().getToken();

    FirebaseFirestore.instance
        .collection('users')
        .doc(myUID)
        .collection(hisUID)
        .add({
      'msg': conversation,
      'sendByMe': true,
      'sendAt': dt,
      'isRead': false,
      'isSent': false
    }).then((value) {
      value.update({'isSent': true});
      print('chated');
      FirebaseFirestore.instance
          .collection('users')
          .doc(hisUID)
          .collection(myUID)
          .doc(value.id)
          .set({
        'msg': conversation,
        'sendByMe': false,
        'sendAt': dt,
        'pushNotificationToken': contact['pushNotificationToken']
      }).then((value) => print('REcent chat added'));
    });

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
      'unseenMsg': 0,
      'uid': contact['uid'],
      'phoneNumber': contact['phoneNumber'],
      'photoURL': contact['photoURL'],
      'pushNotificationToken': contact['pushNotificationToken'],
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
      "unseenMsg": FieldValue.increment(1),
      'lastSignInTime': auth.currentUser.metadata.lastSignInTime,
      'displayName': auth.currentUser.displayName,
      'sendAt': dt,
      'uid': auth.currentUser.uid,
      'phoneNumber': auth.currentUser.phoneNumber,
      'photoURL': auth.currentUser.photoURL,
      'pushNotificationToken': token
    }).then((value) => print('his Recent chat added'));
  }
}
