import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return BottomNavigationBar(items: [
    //   BottomNavigationBarItem(icon: Icon(Icons.home),title: Text('HOME')),
    //   BottomNavigationBarItem(icon: Icon(Icons.search), title: Text('Serch')),
    //   BottomNavigationBarItem(icon: Icon(Icons.add_alert), title: Text('Allert')),
    // ]);
    return BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.transparent,
        elevation: 9.0,
        clipBehavior: Clip.antiAlias,
        child: Container(
            height: 50.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0)),
                color: Colors.black),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      height: 50.0,
                      width: MediaQuery.of(context).size.width / 2 - 40.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(Icons.home, color: Colors.white),
                          Icon(Icons.group, color: Colors.white),
                        ],
                      )),
                  Container(
                      height: 50.0,
                      width: MediaQuery.of(context).size.width / 2 - 40.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(Icons.add_alert, color: Colors.white),
                          Icon(Icons.search, color: Colors.white),
                        ],
                      )),
                ])));
  }
}
