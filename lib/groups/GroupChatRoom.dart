import 'dart:async';
import 'dart:math';

import 'package:Social/Groups.dart';
import 'package:Social/feeds/PostDetail.dart';
import 'package:Social/groups/GroupInfo.dart';
import 'package:Social/groups/MessageInfo.dart';
import 'package:Social/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../ImageGalary.dart';

class GroupChatRoom extends StatefulWidget {
  final dynamic groupID;
  GroupChatRoom({Key key, @required this.groupID}) : super(key: key);

  @override
  _GroupChatRoomState createState() => _GroupChatRoomState(this.groupID);
}

class _GroupChatRoomState extends State<GroupChatRoom> {
  dynamic groupID;
  _GroupChatRoomState(this.groupID);

  TextEditingController sendController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();

  var myUID = FirebaseAuth.instance.currentUser.uid;
  var displayName = FirebaseAuth.instance.currentUser.displayName;
  final key = new GlobalKey<ScaffoldState>();

  void sendMessage() {
    if (sendController.text.trim().toString() != '') {
      GroupsService().addChat(groupID, sendController.text.trim().toString());
      sendController.clear();
    }
  }

  void createPost() {
    if (sendController.text.trim().toString() != '') {
      GroupsService().addChat(groupID, sendController.text.trim().toString());
      sendController.clear();
    }
  }

  void showDialog(chat) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 200),
      context: context,
      useRootNavigator: true,
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.all(20),
            height: 140,
            width: 230,
            child: SizedBox.expand(
                child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                      onTap: () {
                        FirebaseFirestore.instance
                            .collection('groups')
                            .doc('$groupID')
                            .collection('chats')
                            .doc(chat.id)
                            .delete()
                            .then((value) {
                          key.currentState.showSnackBar(new SnackBar(
                            content: new Text("Message Deleted"),
                          ));

                          Navigator.pop(context);
                          Timer(Duration(seconds: 2),
                              () => key.currentState.hideCurrentSnackBar());
                        });
                      },
                      child: Text(
                        'Unsend message',
                        style: TextStyle(
                            color: forground,
                            fontSize: 15,
                            decoration: TextDecoration.none),
                      )),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          new ClipboardData(text: chat.data()['msg']));
                      key.currentState.showSnackBar(new SnackBar(
                        content: new Text("Copied to Clipboard"),
                      ));
                      Timer(Duration(seconds: 2),
                          () => key.currentState.hideCurrentSnackBar());
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Copy text',
                      style: TextStyle(
                          color: forground,
                          fontSize: 15,
                          decoration: TextDecoration.none),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => {
                      Navigator.pop(context),
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MessageInfo(groupID, chat))),
                    },
                    child: Text(
                      'info',
                      style: TextStyle(
                          color: forground,
                          fontSize: 15,
                          decoration: TextDecoration.none),
                    ),
                  ),
                ],
              ),
            )),
            decoration: BoxDecoration(
              color: currentLine,
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        backgroundColor: background,
        iconTheme: IconThemeData(color: forground, size: 30.0),
        
        title: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('groups')
              .doc('$groupID')
              .snapshots(),
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
                          builder: (context) => GroupInfo(groupID, groupInfo)));
                },
                
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(groupInfo['groupPhoto']),
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
        titleSpacing: -10,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(icon: Icon(Icons.call), onPressed: () {}),
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          Container(
            // decoration: BoxDecoration(color: Colors.black),
            decoration: BoxDecoration(color: background),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('groups')
                      .doc('$groupID')
                      .collection('chats')
                      .orderBy('sendAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        reverse: true,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          var chats = snapshot.data.documents[index];
                          int n = snapshot.data.documents.length;
                          bool isContinious = false;
                          if (index < n - 1 &&
                              snapshot.data.documents[index].data()['sendBy']
                                      ['uid'] ==
                                  snapshot.data.documents[index + 1]
                                      .data()['sendBy']['uid'])
                            isContinious = true;

                          if (chats.data()['caption'] == null &&
                              chats.data()['msg'] != null)
                            return InkWell(
                                onLongPress: () {
                                  showDialog(chats);
                                },
                                child: ChatBox(chats, isContinious, groupID));
                          else {
                            return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PostDetail(groupID, chats.id)));
                                },
                                child: PostBox(chats, isContinious, groupID));
                          }
                        });
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(),
                padding: EdgeInsets.only(
                    top: 15.0, left: 10.0, right: 10, bottom: 10),
                alignment: Alignment.bottomCenter,
                child: TypingBox(
                  groupID: groupID,
                ),
              )
            ],
          ),
          Positioned(
            bottom: 80,
            right: 8,
            child: Opacity(
              opacity: 0.5,
              child: Container(
                height: 40.0,
                width: 40.0,
                child: FittedBox(
                  child: FloatingActionButton(
                    onPressed: () {
                      _scrollController.animateTo(
                        0.0,
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 300),
                      );
                    },
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 40,
                    ),
                    backgroundColor: currentLine,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

var colorMap = {};
var colors = [red, yellow, cyan, orange, green, pink, purple];

class TypingBox extends StatefulWidget {
  final dynamic groupID;
  TypingBox({this.groupID});
  @override
  _TypingBoxState createState() => _TypingBoxState(this.groupID);
}

class _TypingBoxState extends State<TypingBox> {
  var groupID;
  _TypingBoxState(this.groupID);
  TextEditingController sendController = new TextEditingController();
  var msg = '';
  void sendMessage() {
    if (sendController.text.trim().toString() != '') {
      GroupsService().addChat(groupID, sendController.text.trim().toString());
      setState(() {
        msg = '';
      });
      sendController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
            onChanged: (value) {
              setState(() {
                msg = value;
              });
            },
            decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(30.0),
                    ),
                    borderSide: BorderSide.none),
                filled: true,
                hintStyle: new TextStyle(color: forground, fontSize: 16),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 13.0, horizontal: 20.0),
                hintText: "Type in your text",
                fillColor: currentLine),
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        if (msg != '')
          Container(
              decoration: BoxDecoration(
                  color: red, borderRadius: BorderRadius.circular(100.0)),
              child: IconButton(
                  iconSize: 23,
                  alignment: Alignment.center,
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    sendMessage();
                  })),
        if (msg == '')
          Container(
              decoration: BoxDecoration(
                  color: currentLine,
                  borderRadius: BorderRadius.circular(100.0)),
              child: IconButton(
                  iconSize: 28,
                  alignment: Alignment.center,
                  icon: Icon(
                    Icons.add_circle,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ImageGallery(groupID)));
                  }))
      ],
    );
  }
}

class ChatBox extends StatelessWidget {
  final dynamic chat;
  final dynamic isContinious;
  final dynamic groupID;
  ChatBox(this.chat, this.isContinious, this.groupID);
  final String myUID = FirebaseAuth.instance.currentUser.uid;
  final String displayName = FirebaseAuth.instance.currentUser.displayName;
  final String photoURL = FirebaseAuth.instance.currentUser.photoURL;
  @override
  Widget build(BuildContext context) {
    var sendByMe = chat.data()['sendBy']['uid'] == myUID;
    if (sendByMe) {
      return Container(
        margin: EdgeInsets.only(top: isContinious ? 4 : 10),
        width: MediaQuery.of(context).size.width,
        color: Colors.transparent,
        alignment: Alignment.centerRight,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: comment,
          ),
          child: Stack(
            children: [
              Container(
                padding:
                    EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 60),
                child: Text(
                  chat.data()['msg'],
                  style: TextStyle(color: forground, fontSize: 16),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 25,
                child: Text(
                  DateFormat.Hm().format(chat.data()['sendAt'].toDate()),
                  style: TextStyle(fontSize: 10, color: Colors.white60),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 7,
                child: chat.data()['isSent']
                    ? false
                        ? Icon(
                            Icons.check_circle,
                            size: 15,
                            color: green,
                          )
                        : Icon(
                            Icons.check_circle_outline,
                            size: 15,
                            color: forground,
                          )
                    : Icon(
                        Icons.access_time,
                        size: 15,
                      ),
              )
            ],
          ),
        ),
      );
    } else {
      if (colorMap[chat.data()['sendBy']['uid']] == null)
        colorMap[chat.data()['sendBy']['uid']] =
            colors[Random().nextInt(colors.length)];
      if (chat.data()['readBy']['$myUID'] == null) {
        // print(groupID);
        FirebaseFirestore.instance
            .collection('groups')
            .doc(groupID)
            .collection('chats')
            .doc(chat.id)
            .update({
          'readBy.$myUID.readAt': DateTime.now(),
          'readBy.$myUID.uid': myUID,
          'readBy.$myUID.photoURL': photoURL,
          'readBy.$myUID.displayName': displayName
        });
      }

      return Container(
        margin: EdgeInsets.only(top: isContinious ? 4 : 10),
        width: MediaQuery.of(context).size.width,
        color: Colors.transparent,
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: currentLine,
          ),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(
                    left: 10,
                    top: isContinious ? 10 : 23,
                    bottom: 10,
                    right: 50),
                child: Text(
                  chat.data()['msg'],
                  style: TextStyle(color: forground, fontSize: 16),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 8,
                child: Text(
                  DateFormat.Hm().format(chat.data()['sendAt'].toDate()),
                  style: TextStyle(fontSize: 10, color: Colors.white60),
                ),
              ),
              if (!isContinious)
                Positioned(
                  top: 5,
                  left: 10,
                  child: Text(
                    chat.data()['sendBy']['displayName'],
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorMap[chat.data()['sendBy']['uid']]),
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }
}

class PostBox extends StatelessWidget {
  final dynamic chat;
  final dynamic isContinious;
  final dynamic groupID;
  PostBox(this.chat, this.isContinious, this.groupID);
  final String myUID = FirebaseAuth.instance.currentUser.uid;
  final String displayName = FirebaseAuth.instance.currentUser.displayName;
  final String photoURL = FirebaseAuth.instance.currentUser.photoURL;
  @override
  Widget build(BuildContext context) {
    var sendByMe = chat.data()['sendBy']['uid'] == myUID;
    if (sendByMe) {
      return Container(
        margin: EdgeInsets.only(top: isContinious ? 4 : 10),
        width: MediaQuery.of(context).size.width,
        color: Colors.transparent,
        alignment: Alignment.centerRight,
        child: Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 130),
          margin: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: comment, width: 2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  color: background,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 6),
                  child: Image.network(chat.data()['imageURL'])),
              Container(
                  width: double.infinity,
                  color: comment,
                  padding: EdgeInsets.only(left: 8, right: 8, top: 5),
                  child: Text('${chat.data()['caption']}')),
              Container(
                color: comment,
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat.Hm().format(chat.data()['sendAt'].toDate()),
                      style: TextStyle(fontSize: 10, color: Colors.white60),
                    ),
                    SizedBox(width: 5),
                    chat.data()['isSent']
                        ? false
                            ? Icon(
                                Icons.check_circle,
                                size: 15,
                                color: green,
                              )
                            : Icon(
                                Icons.check_circle_outline,
                                size: 15,
                                color: forground,
                              )
                        : Icon(
                            Icons.access_time,
                            size: 15,
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    } else {
      if (colorMap[chat.data()['sendBy']['uid']] == null)
        colorMap[chat.data()['sendBy']['uid']] =
            colors[Random().nextInt(colors.length)];
      if (chat.data()['readBy']['$myUID'] == null) {
        // print(groupID);
        FirebaseFirestore.instance
            .collection('groups')
            .doc(groupID)
            .collection('chats')
            .doc(chat.id)
            .update({
          'readBy.$myUID.readAt': DateTime.now(),
          'readBy.$myUID.uid': myUID,
          'readBy.$myUID.photoURL': photoURL,
          'readBy.$myUID.displayName': displayName
        });
      }

      return Container(
        margin: EdgeInsets.only(top: isContinious ? 4 : 10),
        width: MediaQuery.of(context).size.width,
        color: Colors.transparent,
        alignment: Alignment.centerLeft,
        child: Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 130),
          margin: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: currentLine, width: 2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isContinious)
                Container(
                  color: currentLine,
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    chat.data()['sendBy']['displayName'],
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorMap[chat.data()['sendBy']['uid']]),
                  ),
                ),
              Container(
                  color: background,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 6),
                  child: Image.network(chat.data()['imageURL'])),
              Container(
                  width: double.infinity,
                  color: currentLine,
                  padding: EdgeInsets.only(left: 8, right: 8, top: 5),
                  child: Text('${chat.data()['caption']}')),
              Container(
                color: currentLine,
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat.Hm().format(chat.data()['sendAt'].toDate()),
                      style: TextStyle(fontSize: 10, color: Colors.white60),
                    ),
                    SizedBox(width: 5),
                    chat.data()['isSent']
                        ? false
                            ? Icon(
                                Icons.check_circle,
                                size: 15,
                                color: green,
                              )
                            : Icon(
                                Icons.check_circle_outline,
                                size: 15,
                                color: forground,
                              )
                        : Icon(
                            Icons.access_time,
                            size: 15,
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}
