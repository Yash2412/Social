import 'package:Social/Feeds.dart';
import 'package:Social/groups/GroupInfo.dart';
import 'package:Social/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostDetail extends StatefulWidget {
  final dynamic groupID;
  final dynamic postID;
  PostDetail(this.groupID, this.postID);
  @override
  _PostDetailState createState() => _PostDetailState(this.groupID, this.postID);
}

var myUID = FirebaseAuth.instance.currentUser.uid;

class _PostDetailState extends State<PostDetail> {
  var groupID;
  var postID;
  _PostDetailState(this.groupID, this.postID);
  TextEditingController commentController = new TextEditingController();
  ScrollController scrollController = new ScrollController();

  List<Widget> commentList(Map comments) {
    List<Widget> lw = [];
    comments.forEach((key, value) {
      lw.add(CommentBox(value));
    });
    return lw.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        iconTheme: IconThemeData(color: forground, size: 30.0),
        title: Text('Post', style: TextStyle(color: forground)),
        backgroundColor: background,
        titleSpacing: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.only(bottom: 60),
            child: Column(
              children: [
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('groups')
                      .doc('$groupID')
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    var groupInfo = snapshot.data.data();
                    return ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      GroupInfo(groupID, groupInfo)));
                        },
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(groupInfo['groupPhoto']),
                          maxRadius: 20.0,
                          minRadius: 20.0,
                        ),
                        title: Text(groupInfo['groupName']),
                        subtitle: groupInfo['someoneIsTyping'] != null
                            ? Text(groupInfo['someoneIsTyping'])
                            : Text(
                                'tap here for group info',
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
                              ],
                            ),
                          ),
                          Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text('${postInfo['likes'].length} likes')),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc('${postInfo['sendBy']['uid']}')
                                      .get(),
                                  builder: (context, user) {
                                    if (user.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(
                                            left: 15, right: 15, top: 15),
                                        child: CircleAvatar(
                                          child: CircularProgressIndicator(),
                                          maxRadius: 20.0,
                                          minRadius: 20.0,
                                        ),
                                      ));
                                    }
                                    return Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.all(15),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            '${user.data.data()['photoURL']}'),
                                        maxRadius: 20.0,
                                        minRadius: 20.0,
                                      ),
                                    );
                                  }),
                              Container(
                                  width: MediaQuery.of(context).size.width - 80,
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text:
                                              '${postInfo['sendBy']['displayName']} - ',
                                          style: TextStyle(
                                              color: comment,
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(text: '${postInfo['caption']}')
                                    ]),
                                  )),
                            ],
                          ),
                          Divider(
                            height: 0,
                            thickness: 1.5,
                          ),
                          Column(
                            children: commentList(postInfo['comments']),
                          )
                        ],
                      );
                    }),
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: TypingBox(groupID, postID),
          ),
        ],
      ),
    );
  }
}

class TypingBox extends StatelessWidget {
  final dynamic groupID;
  final dynamic postID;
  TypingBox(this.groupID, this.postID);

  final TextEditingController sendController = new TextEditingController();
  void addComment() {
    if (sendController.text.trim().toString() != '') {
      FeedService()
          .addComment(postID, groupID, sendController.text.trim().toString());

      sendController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: currentLine,
      child: Row(
        
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 8,
            child: TextField(
              maxLines: 5,
              minLines: 1,
              style: TextStyle(fontSize: 18, color: forground),
              controller: sendController,
              decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(
                      
                      borderSide: BorderSide.none),
                  filled: true,
                  hintStyle: new TextStyle(color: forground, fontSize: 16),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 13.0, horizontal: 20.0),
                  hintText: "Add a comment",
                  fillColor: Colors.transparent
                  ),
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Container(
              
              child: IconButton(
                  iconSize: 23,
                  alignment: Alignment.center,
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    addComment();
                  })),
        ],
      ),
    );
  }
}

class CommentBox extends StatefulWidget {
  final dynamic postInfo;
  CommentBox(this.postInfo);
  @override
  _CommentBoxState createState() => _CommentBoxState(this.postInfo);
}

class _CommentBoxState extends State<CommentBox> {
  var commentData;
  _CommentBoxState(this.commentData);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc('${commentData['uid']}')
                .get(),
            builder: (context, user) {
              if (user.connectionState == ConnectionState.waiting) {
                return Container();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 15, left: 15, right: 15),
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage('${user.data.data()['photoURL']}'),
                            maxRadius: 20.0,
                            minRadius: 20.0,
                          ),
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width - 80,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text:
                                        '${user.data.data()['displayName']} - ',
                                    style: TextStyle(
                                        color: comment,
                                        fontWeight: FontWeight.bold)),
                                TextSpan(text: '${commentData['comment']}')
                              ]),
                            )),
                      ]),
                  // FlatButton(
                  //   onPressed: () {},
                  //   child: Text(
                  //     'Reply',
                  //     style: TextStyle(color: Colors.grey),
                  //   ),
                  // )
                ],
              );
            }));
  }
}
