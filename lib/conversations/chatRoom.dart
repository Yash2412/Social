import 'package:Social/User.dart';
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

  void sendMessage() {
    UserService().addChat(contact, sendController.text.trim().toString());
    sendController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Stream collectionStream = FirebaseFirestore.instance
        .collection('users')
        .doc(myUID)
        .collection(contact['uid'].toString())
        .orderBy('sendAt', descending: true)
        .snapshots();
    var fifteenAgo =
        DateTime.now().difference(contact['lastSignInTime'].toDate());
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black54, size: 30.0),
        title: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(contact['photoURL']),
              maxRadius: 24.0,
              minRadius: 20.0,
            ),
            title: Text(contact['displayName']),
            subtitle: Text(
                timeago.format(DateTime.now().subtract(fifteenAgo),
                    locale: 'en'),
                style: TextStyle(fontSize: 10))),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        titleSpacing: 0.0,
        actions: [
          IconButton(icon: Icon(Icons.call), onPressed: () {}),
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          Container(
            // decoration: BoxDecoration(color: Colors.black),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xffdfe9f3), Color(0xffffffff)])),
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
                        controller: sendController,
                        decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(30.0),
                                ),
                                borderSide: BorderSide.none),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: IconButton(
                                  icon: Icon(
                                    Icons.broken_image,
                                    size: 30.0,
                                  ),
                                  onPressed: () {}),
                            ),
                            filled: true,
                            hintStyle: new TextStyle(color: Colors.grey[800]),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 20.0),
                            hintText: "Type in your text",
                            fillColor: Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
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
}

class ChatBox extends StatelessWidget {
  final dynamic chat;
  ChatBox(this.chat);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment:
          chat['sendByMe'] ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: chat['sendByMe'] ? Colors.black12 : Colors.white,
        ),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 1.5),
        child: Stack(
          children: [
            Container(
              padding:
                  EdgeInsets.only(left: 10, top: 10, bottom: 15, right: 45),
              child: Text(
                chat['msg'],
                style: TextStyle(color: Colors.black),
              ),
            ),
            Positioned(
              bottom: 5,
              right: 8,
              child: Text(
                DateFormat.Hm().format(chat['sendAt'].toDate()),
                style: TextStyle(fontSize: 10),
              ),
            )
          ],
        ),
      ),
    );
  }
}
