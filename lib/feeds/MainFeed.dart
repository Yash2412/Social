import 'package:Social/feeds/PostDetail.dart';
import 'package:Social/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Feeds.dart';

class MainFeed extends StatefulWidget {
  @override
  _MainFeedState createState() => _MainFeedState();
}

var myUID = FirebaseAuth.instance.currentUser.uid;

class _MainFeedState extends State<MainFeed> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          iconTheme: IconThemeData(color: forground, size: 30.0),
          title: Text('Post', style: TextStyle(color: forground)),
          backgroundColor: background,
        ),
        body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc('$myUID')
              .collection('posts')
              .orderBy('sendAt', descending: true)
              .get(),
          builder: (context, posts) {
            if (posts.hasError) {
              return Text('Something went wrong');
            }

            if (posts.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView.separated(
              itemCount: posts.data.documents.length,
              separatorBuilder: (context, index) {
                return Divider(color: currentLine, thickness: 1.5);
              },
              itemBuilder: (context, index) {
                var groupID = posts.data.documents[index].data()['groupID'];
                var postID = posts.data.documents[index].id;
                return FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('groups')
                      .doc('$groupID')
                      .collection('chats')
                      .doc('$postID')
                      .get(),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snap.connectionState == ConnectionState.waiting) {
                      return Container();
                    }
                    return MainPostBox(snap.data, groupID, postID);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class MainPostBox extends StatefulWidget {
  final dynamic postData;
  final dynamic groupID;
  final dynamic postID;
  MainPostBox(this.postData, this.groupID, this.postID);
  @override
  _MainPostBoxState createState() =>
      _MainPostBoxState(this.postData, this.groupID, this.postID);
}

class _MainPostBoxState extends State<MainPostBox> {
  dynamic postData;
  dynamic groupID;
  dynamic postID;

  _MainPostBoxState(this.postData, this.groupID, this.postID);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: Future.wait([
            FirebaseFirestore.instance
                .collection('users')
                .doc('${postData.data()['sendBy']['uid']}')
                .get(),
            FirebaseFirestore.instance
                .collection('groups')
                .doc('$groupID')
                .get()
          ]),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            var userInfo = snapshot.data[0].data();
            var groupInfo = snapshot.data[1].data();
            return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(userInfo['photoURL']),
                  maxRadius: 20.0,
                  minRadius: 20.0,
                ),
                title: Text(userInfo['displayName']),
                subtitle: Text(
                  groupInfo['groupName'],
                  style: TextStyle(fontSize: 10),
                ));
          },
        ),
        StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .doc('$groupID')
                .collection('chats')
                .doc(postID)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              var postInfo = snapshot.data.data();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(maxHeight: 400),
                    decoration: BoxDecoration(
                      color: background,
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          // colorFilter: ColorFilter.mode(
                          //     Colors.black.withOpacity(0.8), BlendMode.dstATop),
                          image: NetworkImage(postInfo['imageURL'])),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.thumb_up,
                                  color: postInfo['likes'].contains(myUID)
                                      ? comment
                                      : forground,
                                ),
                                onPressed: () {
                                  if (postInfo['likes'].contains(myUID)) {
                                    FeedService().removeLike(postID, groupID);
                                  } else {
                                    FeedService()
                                        .incrementLike(postID, groupID);
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.add_comment,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PostDetail(groupID, postID)));
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('${postInfo['likes'].length} likes')),
                      ],
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      margin: EdgeInsets.only(bottom: 10),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: '${postInfo['sendBy']['displayName']} ',
                              style: TextStyle(
                                  color: comment, fontWeight: FontWeight.bold)),
                          TextSpan(text: '${postInfo['caption']}')
                        ]),
                      )),
                ],
              );
            }),
      ],
    );
  }
}
