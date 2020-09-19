import 'package:Social/conversations/recentChats.dart';
import 'package:Social/home/hubs.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _active = 1;

  var tabs = [
    Hubs(),
    RecentChats(),
    Center(
      child: Text('Feeds'),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[_active],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0.0,
        iconSize: 25.0,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        fixedColor: Colors.black,
        currentIndex: _active,
        onTap: (index) {
          print(index);
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
}

/*
class BottomBar extends StatelessWidget {
  @override
  
    // return BottomAppBar(
    //     shape: CircularNotchedRectangle(),
    //     notchMargin: 6.0,
    //     color: Colors.transparent,
    //     elevation: 9.0,
    //     clipBehavior: Clip.antiAlias,
    //     child: Container(
    //         height: 50.0,
    //         decoration: BoxDecoration(
    //             borderRadius: BorderRadius.only(
    //                 topLeft: Radius.circular(25.0),
    //                 topRight: Radius.circular(25.0)),
    //             color: Colors.black),
    //         child: Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               Container(
    //                   height: 50.0,
    //                   width: MediaQuery.of(context).size.width / 2 - 40.0,
    //                   child: Row(
    //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                     children: <Widget>[
    //                       Icon(Icons.home, color: Colors.white),
    //                       Icon(Icons.group, color: Colors.white),
    //                     ],
    //                   )),
    //               Container(
    //                   height: 50.0,
    //                   width: MediaQuery.of(context).size.width / 2 - 40.0,
    //                   child: Row(
    //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                     children: <Widget>[
    //                       Icon(Icons.add_alert, color: Colors.white),
    //                       Icon(Icons.search, color: Colors.white),
    //                     ],
    //                   )),
    //             ])));
  }
}
*/
