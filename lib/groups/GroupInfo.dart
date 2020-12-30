import 'package:Social/groups/EditGroupDetails.dart';
import 'package:intl/intl.dart';
import 'package:Social/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final dynamic groupId;
  final dynamic groupInfo;

  GroupInfo(this.groupId, this.groupInfo);

  @override
  _GroupInfoState createState() =>
      _GroupInfoState(this.groupId, this.groupInfo);
}

class _GroupInfoState extends State<GroupInfo> {
  dynamic groupID;
  dynamic groupInfo;
  _GroupInfoState(this.groupID, this.groupInfo);

  editGroup() async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditGroupDetails(groupID, groupInfo),
        )).then((info) {
      if (info != null && info != []) setState(() => groupInfo = info);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: background,
          ),
          FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('groups')
                  .doc('$groupID')
                  .collection('members')
                  .orderBy('displayName')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                var participants = snapshot.data.documents;
                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: background,
                      expandedHeight: 500,
                      elevation: 0,
                      iconTheme: IconThemeData(color: forground, size: 30.0),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: BoxDecoration(
                            color: background,
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.8),
                                    BlendMode.dstATop),
                                image: NetworkImage(
                                  groupInfo['groupPhoto'],
                                )),
                          ),
                        ),
                        title: Container(
                            child: ListTile(
                          title: Text('${groupInfo['groupName']}',
                              style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: forground)),
                          subtitle: Text(
                              'Created on ${DateFormat.MMMMEEEEd().format(groupInfo['createdAt'].toDate())}',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: forground)),
                          trailing: Container(
                            alignment: Alignment.bottomRight,
                            width: 20,
                            height: 20,
                            child: IconButton(

                              icon: Icon(
                                Icons.edit,
                                size: 20,
                                color: orange,
                                
                              ),
                              onPressed: () {
                                editGroup();
                              },
                              color: forground,
                              splashColor: currentLine,
                            ),
                          ),
                        )),
                        titlePadding: EdgeInsets.only(left: 50, bottom: 10),
                      ),
                      floating: true,
                      pinned: true,
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 5,
                        child: Container(color: currentLine),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 40,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 15),
                          color: background,
                          child: Text(
                            '${participants.length} Participants',
                            style: TextStyle(
                                color: yellow, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                        delegate: SliverChildBuilderDelegate(
                            // return Text('${snapshot.data.documents[0].data()}');

                            (context, index) {
                      var member = participants[index].data();
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                            borderRadius: index == 0
                                ? BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    topRight: Radius.circular(5))
                                : index == participants.length - 1
                                    ? BorderRadius.only(
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(5))
                                    : BorderRadius.zero,
                            color: currentLine),
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(member['photoURL']),
                                maxRadius: 20.0,
                                minRadius: 20.0,
                              ),
                              title: Text(
                                member['displayName'],
                                style: TextStyle(
                                    color: forground,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Divider(thickness: 1.5)
                          ],
                        ),
                      );
                    }, childCount: participants.length)),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
