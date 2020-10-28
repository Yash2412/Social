import 'package:Social/Groups.dart';
import 'package:Social/groups/GroupChatRoom.dart';
import 'package:Social/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget _buildCard(String name, String groupId) {
  return Padding(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
      child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('groups')
              .doc('$groupId')
              .get(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: SpinKitPulse(color: Colors.white));
            }
            var info = snapshot.data.data();
            return Container(
                child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(info['groupPhoto']),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 0.8,
                            blurRadius: 3.0)
                      ],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                  height: 40,
                  child: Text(
                    '${info['groupName']}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: forground),
                  ),
                )
              ],
            ));
          }));
}

class MastiGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: GroupsService().getAllGroups('Masti Group'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitPulse(color: Colors.white));
          }
          if (!snapshot.hasData)
            return Center(
              child: Text('Opps! You have nothing here'),
            );

          return Container(
              padding: EdgeInsets.all(10),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.7,
                children: snapshot.data.documents.map<Widget>((document) {
                  return InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupChatRoom(
                                    groupID: document.id,
                                  )));
                    },
                    child:
                        _buildCard(document.data()['groupName'], document.id),
                  );
                }).toList(),
              ));
        });
  }
}

class WorkingGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: GroupsService().getAllGroups('Working Group'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitPulse(color: Colors.white));
          }
          if (!snapshot.hasData)
            return Center(
              child: Text('Opps! You have nothing here'),
            );

          return Container(
              padding: EdgeInsets.all(10),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.7,
                children: snapshot.data.documents.map<Widget>((document) {
                  return InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupChatRoom(
                                    groupID: document.id,
                                  )));
                    },
                    child:
                        _buildCard(document.data()['groupName'], document.id),
                  );
                }).toList(),
              ));
        });
  }
}

class FamilyGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: GroupsService().getAllGroups('Family Group'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitPulse(color: Colors.white));
          }
          if (snapshot.data.documents.length == 0)
            return Center(
              child: Text('Opps! You have nothing here'),
            );
          return Container(
              padding: EdgeInsets.all(10),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.7,
                children: snapshot.data.documents.map<Widget>((document) {
                  return InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupChatRoom(
                                    groupID: document.id,
                                  )));
                    },
                    child:
                        _buildCard(document.data()['groupName'], document.id),
                  );
                }).toList(),
              ));
        });
  }
}
