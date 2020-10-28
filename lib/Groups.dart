import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GroupsService {
  var myUID = FirebaseAuth.instance.currentUser.uid;
  var displayName = FirebaseAuth.instance.currentUser.displayName;
  var photoURL = FirebaseAuth.instance.currentUser.photoURL;
  var phoneNumber = FirebaseAuth.instance.currentUser.phoneNumber;

  String randomString([int length = 16]) {
    Random _random = Random.secure();
    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }

  Future<String> uploadPic(File image, path, groupID) async {
    print('Uploading Image...');

    FirebaseStorage _storage = FirebaseStorage.instance;

    //Create a reference to the location you want to upload to in firebase
    StorageReference ref = _storage.ref().child("$path/");
    //Upload the file to firebase
    StorageUploadTask storageUploadTask = ref.child(groupID).putFile(image);

    storageUploadTask.events.listen((event) {
      double percentage = 100 *
          (event.snapshot.bytesTransferred.toDouble() /
              event.snapshot.totalByteCount.toDouble());
      print("THe percentage " + percentage.toString());
    });

    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;
    var pg = (await storageTaskSnapshot.ref.getDownloadURL()).toString();

    return pg;
  }

  Future<dynamic> createGroup(
      participants, groupName, File image, groupType) async {
    participants[myUID] = {
      'displayName': displayName,
      "photoURL": photoURL,
      "phoneNumber": phoneNumber,
      "uid": myUID
    };

    var newGroup = await FirebaseFirestore.instance.collection('groups').add({
      "createdAt": DateTime.now(),
      "createdBy": myUID,
      "noOfMembers": participants.length,
      "groupPhoto": '',
      "groupName": groupName,
      "groupType": groupType
    });
    var groupPhoto;
    if (image != null)
      groupPhoto = await uploadPic(image, 'GroupPics', newGroup.id);
    else
      groupPhoto =
          "https://firebasestorage.googleapis.com/v0/b/social-2c1f3.appspot.com/o/DummyImage%2Fdummy.jpg?alt=media&token=ed596480-73b0-4269-ada7-9e2c207df683";

    await newGroup.update({'groupPhoto': groupPhoto});
    participants.forEach((uid, contact) {
      FirebaseFirestore.instance
          .doc('groups/${newGroup.id}/members/$uid')
          .set(contact)
          .then((value) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('groups')
            .doc('${newGroup.id}')
            .set({
          'createdAt': DateTime.now(),
          'groupType': groupType,
          'groupName': groupName,
          'groupPhoto': groupPhoto
        }).then((value) => print('Added for $uid'));
      });
    });

    return newGroup.id;
  }

  getAllGroups(type) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc('$myUID')
        .collection('groups')
        .where('groupType', isEqualTo: type)
        .snapshots();
  }

  editGroupData(groupId, groupName, File image, groupType) async {
    if (image != null) {
      var groupPhoto = await uploadPic(image, 'GroupPics', groupId);
      FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        "groupPhoto": groupPhoto,
        "groupName": groupName,
        "groupType": groupType
      });
    } else {
      FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .update({"groupName": groupName, "groupType": groupType});
    }
    var res = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .get();
    return res.data();
  }

  addChat(groupId, chat) {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .add({
      'msg': chat,
      'sendBy': {
        'uid': myUID,
        'displayName': displayName,
      },
      'sendAt': DateTime.now(),
      'isSent': false,
      'readBy': {}
    }).then((value) {
      value.update({'isSent': true});
      print('Group Chat Added');
    });
  }

  Future<dynamic> addPost(groupId, post) async {
    Directory systemTempDir = Directory.systemTemp;
    File image = await new File('${systemTempDir.path}/foo.png').create();
    image.writeAsBytes(post['media']);
    var imageURL =
        await uploadPic(image, 'GroupPosts/$groupId', randomString());

    var time = DateTime.now();

    var res = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .add({
      'caption': post['caption'],
      'sendBy': {
        'uid': myUID,
        'displayName': displayName,
      },
      'imageURL': imageURL,
      'sendAt': time,
      'isSent': false,
      'readBy': {},
      'likes': [],
      'groupID': groupId,
      'comments': {}
    });

    res.then((value) {
      value.update({'isSent': true});
      FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .get()
          .then((snap) {
        snap.docs.forEach((element) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(element.data()['uid'])
              .collection('posts')
              .doc(value.id)
              .set({
            'groupID': groupId,
            'sendAt': time,
          });
        });
      });
    });
    print('Group Post Added for $groupId');

    return res;
  }
}
