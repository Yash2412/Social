import 'package:Social/conversations/recentChats.dart';
import 'package:Social/feeds/MainFeed.dart';
import 'package:Social/home/hubs.dart';
import 'package:Social/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  var myUID = FirebaseAuth.instance.currentUser.uid;

  int _active = 1;

  var tabs = [
    Hubs(),
    RecentChats(),
    MainFeed()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[_active],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0.0,
        backgroundColor: background,
        fixedColor: orange,
        iconSize: 25.0,
        selectedFontSize: 15,
        unselectedFontSize: 12,
        currentIndex: _active,
        onTap: (index) {
          setState(() {
            _active = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), title: Text('Hub')),
          BottomNavigationBarItem(
              activeIcon: Icon(Icons.chat_bubble),
              icon: Icon(Icons.chat_bubble_outline),
              title: Text('Chat')),
          BottomNavigationBarItem(
              icon: Icon(Icons.view_day), title: Text('Feeds')),
        ],
      ),
    );
  }

  pushNotification() {
    FirebaseMessaging().configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        FirebaseFirestore.instance
            .doc(
                'users/${message['data']['recipient']}/$myUID/${message['data']['doc']}')
            .update({"isDelivered": true});
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  @override
  void initState() {
    super.initState();
    pushNotification();

    WidgetsBinding.instance.addObserver(this);
    FirebaseFirestore.instance
        .collection('users')
        .doc(myUID)
        .update({'lastSceen': DateTime.now(), 'isOnline': true});
  }

  @override
  void dispose() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(myUID)
        .update({'lastSceen': DateTime.now(), 'isOnline': false});
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);

    if (state == AppLifecycleState.resumed) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(myUID)
          .update({'lastSceen': DateTime.now(), 'isOnline': true});
    } else
      FirebaseFirestore.instance
          .collection('users')
          .doc(myUID)
          .update({'lastSceen': DateTime.now(), 'isOnline': false});
  }
}
