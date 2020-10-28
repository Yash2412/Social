import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedService {
  var myUID = FirebaseAuth.instance.currentUser.uid;
  var displayName = FirebaseAuth.instance.currentUser.displayName;
  var photoURL = FirebaseAuth.instance.currentUser.photoURL;
  var phoneNumber = FirebaseAuth.instance.currentUser.phoneNumber;

  incrementLike(var postId, var groupId) {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .doc(postId)
        .update({
      'likes': FieldValue.arrayUnion([myUID])
    });
  }
  removeLike(var postId, var groupId) {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .doc(postId)
        .update({
      'likes': FieldValue.arrayRemove([myUID])
    });
  }

  addComment(var postId, var groupId, var comment) {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .doc(postId)
        .set({
      'comments': {
        '${DateTime.now()}': {'comment': comment, 'uid': myUID, 'replys': {}}
      }
    }, SetOptions(merge: true));
  }
}
