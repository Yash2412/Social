import 'package:Social/conversations/AllContacts.dart';
import 'package:Social/theme/theme.dart';
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

  checkUpdate(contact) {
    FirebaseFirestore.instance
        .doc('users/${contact['uid']}')
        .get()
        .then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(myUID)
          .collection('RecentChats')
          .doc(contact['uid'])
          .update(value.data());
    });
  }

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
          style: TextStyle(fontSize: 20.0, color: forground),
        ),
        backgroundColor: background,
        centerTitle: false,
        titleSpacing: 20.0,
        actions: [
          IconButton(
              iconSize: 25.0,
              icon: Icon(
                Icons.search,
                color: forground,
              ),
              onPressed: null),
        ],
      ),
      body: Stack(
        children: [
          Container(
            // decoration: BoxDecoration(color: Colors.black),
            decoration: BoxDecoration(color: background),
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
                            color: Colors.black,
                            height: 0,
                          );
                        },
                        reverse: false,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          dynamic contact =
                              snapshot.data.documents[index].data();
                          checkUpdate(contact);
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
                              maxRadius: 20.0,
                              minRadius: 20.0,
                            ),
                            title: Text(
                              contact['displayName'],
                              style: TextStyle(
                                  color: forground,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600),
                            ),
                            isThreeLine: false,
                            subtitle: Text(
                              contact['lastMsg'].toString().length > 30
                                  ? '${contact['lastMsg'].toString().substring(0, 30)} ....'
                                  : contact['lastMsg'].toString(),
                              style: TextStyle(color: cyan),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                    timeago.format(
                                        DateTime.now().subtract(fifteenAgo),
                                        locale: 'en_short'),
                                    style: TextStyle(
                                      fontSize: 10,
                                    )),
                                Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: comment,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Text(
                                      '20',
                                      style: TextStyle(
                                          color: forground,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ))
                              ],
                            ),
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
          backgroundColor: comment,
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
              color: forground,
            ),
            iconSize: 30.0,
            tooltip: "New Chat",
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
