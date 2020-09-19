import 'package:Social/conversations/AllContacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chatRoom.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecentChats extends StatefulWidget {
  @override
  _RecentChatsState createState() => _RecentChatsState();
}

class _RecentChatsState extends State<RecentChats> {
  String myUID = FirebaseAuth.instance.currentUser.uid;
  @override
  Widget build(BuildContext context) {
    Stream collectionStream = FirebaseFirestore.instance
        .collection('users')
        .doc(myUID)
        .collection('RecentChats')
        .orderBy('sendAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Conversations",
          style: TextStyle(fontSize: 22.0, color: Colors.black54),
        ),
        backgroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 20.0,
        actions: [
          IconButton(
              iconSize: 30.0,
              icon: Icon(
                Icons.search,
                color: Colors.deepPurple,
              ),
              onPressed: null),
          SizedBox(
            width: 20.0,
          )
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
          Container(
              child: StreamBuilder(
                  stream: collectionStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData) {
                      return ListView.separated(
                        separatorBuilder: (context, index) {
                          return Divider(
                            indent: 75.0,
                            thickness: 0.5,
                            endIndent: 15,
                            color: Colors.grey,
                          );
                        },
                        reverse: false,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          dynamic contact =
                              snapshot.data.documents[index].data();
                          var fifteenAgo = DateTime.now()
                              .difference(contact['sendAt'].toDate());
                          return ListTile(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChatRoom(contact: contact),
                                )),
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(contact['photoURL']),
                              maxRadius: 24.0,
                              minRadius: 20.0,
                            ),
                            title: Text(contact['displayName']),
                            isThreeLine: false,
                            subtitle: Text(contact['lastMsg']
                                        .toString()
                                        .length >
                                    30
                                ? '${contact['lastMsg'].toString().substring(0, 30)} ....'
                                : contact['lastMsg'].toString()),
                            trailing: Text(
                                timeago.format(
                                    DateTime.now().subtract(fifteenAgo),
                                    locale: 'en_short'),
                                style: TextStyle(fontSize: 10)),
                          );
                        },
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  })),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.blueAccent,
          child: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => (AllContacts()),
                  ));
            },
            icon: Icon(
              Icons.add,
            ),
            iconSize: 30.0,
            tooltip: "New Chat",
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
