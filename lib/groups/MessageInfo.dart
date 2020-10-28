import 'package:Social/groups/GroupChatRoom.dart';
import 'package:Social/theme/theme.dart';
import 'package:flutter/material.dart';

class MessageInfo extends StatefulWidget {
  final dynamic groupId;
  final dynamic messageInfo;

  MessageInfo(this.groupId, this.messageInfo);

  @override
  _MessageInfoState createState() =>
      _MessageInfoState(this.groupId, this.messageInfo);
}

class _MessageInfoState extends State<MessageInfo> {
  dynamic groupID;
  dynamic messageInfo;
  _MessageInfoState(this.groupID, this.messageInfo);

  getAllReads() {
    List<Widget> resWidget = [];
    int index = 0;
    int n = messageInfo.data()['readBy'].length;
    messageInfo.data()['readBy'].forEach((id, member) => {
          resWidget.add(Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                borderRadius: index == n - 1
                    ? BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))
                    : BorderRadius.zero,
                color: currentLine),
            child: Column(
              children: [
                ListTile(
               
                  title: Text(
                    member['displayName'],
                    style: TextStyle(
                        color: forground,
                        fontSize: 17,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Divider(thickness: 1.5,height: 1.5,)
              ],
            ),
          )),
          index++
        });
    return resWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: background,
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: background,
                expandedHeight: 130,
                elevation: 0,
                iconTheme: IconThemeData(color: forground, size: 30.0),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: background,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ChatBox(messageInfo,false, groupID),
                      ],
                    ),
                  ),
                ),
                floating: true,
                pinned: true,
                title: Text(
                  'Message Info',
                  style: TextStyle(color: forground, fontSize: 22),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 5,
                  child: Divider(
                    color: currentLine,
                    thickness: 5,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                    height: 60,
                    child: Container(
                      margin: EdgeInsets.only(left: 15, right: 15, top: 20),
                      padding: EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          color: currentLine),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Read By ${messageInfo.data()['readBy'].length}',
                            style: TextStyle(color: forground,fontSize: 18),
                          ),
                          Divider(thickness: 1.5,height: 1.5,)
                        ],
                      ),
                    )),
              ),
              SliverList(delegate: SliverChildListDelegate(getAllReads())),
              
            ],
          )
        ],
      ),
    );
  }
}
