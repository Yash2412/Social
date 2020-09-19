import 'package:Social/home/firstPage.dart';
import 'package:flutter/material.dart';

class Hubs extends StatefulWidget {
  @override
  _HubsState createState() => _HubsState();
}

class _HubsState extends State<Hubs> with TickerProviderStateMixin{

TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }


  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
    );
  }
}
