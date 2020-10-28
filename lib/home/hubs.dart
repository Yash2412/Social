import 'package:Social/groups/AllContactsForGroup.dart';
import 'package:Social/home/AllTypesOfGroup.dart';
import 'package:Social/theme/theme.dart';
import 'package:flutter/material.dart';

class Hubs extends StatefulWidget {
  @override
  _HubsState createState() => _HubsState();
}

class _HubsState extends State<Hubs> with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: background,
        title: Text('All Hubs',
            style: TextStyle(
                fontSize: 25.0, fontWeight: FontWeight.w800, color: forground)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications_none, color: forground),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
            controller: _tabController,
            indicatorColor: comment,
            labelColor: comment,
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            unselectedLabelStyle:
                TextStyle(fontSize: 8.0, fontWeight: FontWeight.w300),
            isScrollable: true,
            unselectedLabelColor: currentLine,
            tabs: [
              Tab(
                child: Text('Masti Group',
                    style:
                        TextStyle(fontSize: 21.0, fontWeight: FontWeight.w700)),
              ),
              Tab(
                child: Text('Working Group',
                    style:
                        TextStyle(fontSize: 21.0, fontWeight: FontWeight.w700)),
              ),
              Tab(
                child: Text('Family Group',
                    style:
                        TextStyle(fontSize: 21.0, fontWeight: FontWeight.w700)),
              )
            ]),
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          height: MediaQuery.of(context).size.height - 50.0,
          width: double.infinity,
          child: TabBarView(controller: _tabController, children: [
            MastiGroup(),
            WorkingGroup(),
            FamilyGroup(),
          ])),
      backgroundColor: background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => (AllContactsForGroup()),
              ));
        },
        backgroundColor: comment,
        child: Icon(
          Icons.add,
          color: forground,
          size: 30,
        ),
        tooltip: "New Chat",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

