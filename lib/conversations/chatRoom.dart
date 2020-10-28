import 'package:Social/User.dart';
import 'package:Social/theme/theme.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ChatRoom extends StatefulWidget {
  final dynamic contact;
  ChatRoom({Key key, @required this.contact}) : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState(this.contact);
}

class _ChatRoomState extends State<ChatRoom> {
  dynamic contact;
  _ChatRoomState(this.contact);
  String myUID = FirebaseAuth.instance.currentUser.uid;
  bool _isAtBottom = true;

  TextEditingController sendController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(myUID)
            .update({"isTyping": visible});
      },
    );
  }

  void sendMessage() {
    if (sendController.text.trim().toString() != '') {
      UserService().addChat(contact, sendController.text.trim().toString());
      sendController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    Stream collectionStream = FirebaseFirestore.instance
        .collection('users')
        .doc(myUID)
        .collection(contact['uid'].toString())
        .orderBy('sendAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: forground, size: 30.0),
        title: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(contact['photoURL']),
              maxRadius: 20.0,
              minRadius: 20.0,
            ),
            title: Text(contact['displayName']),
            subtitle: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(contact['uid'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var fifteenAgo = DateTime.now()
                      .difference(snapshot.data.data()['lastSceen'].toDate());
                  return snapshot.data.data()['isOnline']
                      ? snapshot.data.data()['isTyping']
                          ? Text('typing...', style: TextStyle(fontSize: 10))
                          : Text('Online', style: TextStyle(fontSize: 10))
                      : Text(
                          'Active ${timeago.format(DateTime.now().subtract(fifteenAgo), locale: 'en')}',
                          style: TextStyle(fontSize: 10));
                },
                initialData: contact['isOnline']
                    ? Text('Online', style: TextStyle(fontSize: 10))
                    : Text(
                        'Active ${timeago.format(DateTime.now().subtract(DateTime.now().difference(contact['lastSceen'].toDate())), locale: 'en')}',
                        style: TextStyle(fontSize: 10)))),
        backgroundColor: background,
        automaticallyImplyLeading: true,
        titleSpacing: -10,
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
                  stream: collectionStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        if (!snapshot.data.documents[index]
                            .data()['sendByMe']) {
                          FirebaseFirestore.instance
                              .doc(
                                  'users/${contact['uid']}/$myUID/${snapshot.data.documents[index].documentID}')
                              .update({'isRead': true});
                          FirebaseFirestore.instance
                              .doc('users/$myUID/RecentChats/${contact['uid']}')
                              .update({'unseenMsg': 0});
                        }
                        return ChatBox(snapshot.data.documents[index].data());
                      },
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                alignment: Alignment.bottomCenter,
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
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(30.0),
                                ),
                                borderSide: BorderSide.none),
                            filled: true,
                            hintStyle:
                                new TextStyle(color: forground, fontSize: 16),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 13.0, horizontal: 20.0),
                            hintText: "Type in your text",
                            fillColor: currentLine),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: red,
                            borderRadius: BorderRadius.circular(100.0)),
                        child: IconButton(
                            iconSize: 23,
                            alignment: Alignment.center,
                            icon: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              sendMessage();
                            }))
                  ],
                ),
              )
            ],
          ),
          if (!_isAtBottom)
            Positioned(
              bottom: 80,
              right: 8,
              child: Container(
                height: 30.0,
                width: 30.0,
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
                      Icons.arrow_downward,
                      color: Colors.white,
                      size: 40,
                    ),
                    backgroundColor: Colors.black45,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    sendController.dispose();
    super.dispose();
  }
}

class ChatBox extends StatelessWidget {
  final dynamic chat;
  ChatBox(this.chat);

  @override
  Widget build(BuildContext context) {
    var isSelected = false;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1),
      padding: EdgeInsets.symmetric(vertical: 3),
      width: MediaQuery.of(context).size.width,
      color: isSelected
          ? comment.withAlpha(100).withOpacity(0.5)
          : Colors.transparent,
      alignment:
          chat['sendByMe'] ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: !chat['sendByMe'] ? comment : currentLine,
        ),
        child: Stack(
          children: [
            Container(
              padding:
                  EdgeInsets.only(left: 10, top: 10, bottom: 15, right: 50),
              child: Text(
                chat['msg'],
                style: TextStyle(color: forground, fontSize: 16),
              ),
            ),
            Positioned(
              bottom: 5,
              right: (chat['sendByMe']) ? 25 : 8,
              child: Text(
                DateFormat.Hm().format(chat['sendAt'].toDate()),
                style: TextStyle(fontSize: 10, color: Colors.white60),
              ),
            ),
            if (chat['sendByMe'])
              Positioned(
                bottom: 5,
                right: 7,
                child: chat['isSent']
                    ? chat['isRead']
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
  }
}
