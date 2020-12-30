import 'package:Social/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;


class HisInfo extends StatefulWidget {
  final dynamic hisUId;
  HisInfo(this.hisUId);

  @override
  _HisInfoState createState() => _HisInfoState(this.hisUId);
}

class _HisInfoState extends State<HisInfo> {
  dynamic hisUID;
  _HisInfoState(this.hisUID);

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
                  .collection('users')
                  .doc('$hisUID')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                var hisDetails = snapshot.data.data();
                var fifteenAgo = DateTime.now()
                      .difference(hisDetails['lastSceen'].toDate());
                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: background,
                      expandedHeight: 400,
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
                                  hisDetails['photoURL'],
                                )),
                          ),
                        ),
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
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        color: background,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${hisDetails['displayName']}',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: forground)),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              '${hisDetails['phoneNumber']}',
                              style: TextStyle(
                                  color: forground, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 5,
                        child: Container(color: currentLine),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        color: background,
                        child: Text(
                          'Active ${timeago.format(DateTime.now().subtract(fifteenAgo), locale: 'en')}',
                          style: TextStyle(
                            fontSize: 15,
                              color: forground, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
