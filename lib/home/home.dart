import 'package:flutter/material.dart';

import 'bottom_bar.dart';
import 'firstPage.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   // centerTitle: true,
      //   // leading: IconButton(
      //   //   icon: Icon(Icons.arrow_back, color: Color(0xFF545D68)),
      //   //   onPressed: () {},
      //   // ),
      //   titleSpacing: 20.0,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: MediaQuery.of(context).size.height * 0.15,
            floating: true,
            pinned: true,
            title: Text('CHUSKI',
                style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF545D68))),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.notifications_none, color: Color(0xFF545D68)),
                onPressed: () {},
              ),
            ],
            bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.transparent,
                labelColor: Colors.grey[800],
                isScrollable: true,
                unselectedLabelColor: Color(0xFFCDCDCD),
                tabs: [
                  Tab(
                    child: Text('Masti Group',
                        style: TextStyle(
                            fontSize: 21.0, fontWeight: FontWeight.w700)),
                  ),
                  Tab(
                    child: Text('Working Group',
                        style: TextStyle(
                            fontSize: 21.0, fontWeight: FontWeight.w700)),
                  ),
                  Tab(
                    child: Text('Family Group',
                        style: TextStyle(
                            fontSize: 21.0, fontWeight: FontWeight.w700)),
                  )
                ]),
          ),
          SliverToBoxAdapter(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                height: MediaQuery.of(context).size.height - 50.0,
                width: double.infinity,
                child: TabBarView(controller: _tabController, children: [
                  CookiePage(),
                  CookiePage(),
                  CookiePage(),
                ])),
          ),
        ],
      ),
      // body: ListView(
      //   padding: EdgeInsets.only(left: 20.0),
      //   children: <Widget>[
      //     SizedBox(height: 15.0),
      //     Text('Groups',
      //         style: TextStyle(fontSize: 42.0, fontWeight: FontWeight.bold)),
      //     SizedBox(height: 15.0),
      //     Container(
      //         height: MediaQuery.of(context).size.height - 50.0,
      //         width: double.infinity,
      //         child: TabBarView(controller: _tabController, children: [
      //           CookiePage(),
      //           CookiePage(),
      //           CookiePage(),
      //         ]))
      //   ],
      // ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.black,
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.chat,
            ),
            iconSize: 30.0,
            tooltip: "Chat",
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomBar(),
    );
  }
}
