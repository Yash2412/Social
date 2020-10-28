import 'dart:io';
import 'package:Social/Groups.dart';
import 'package:Social/groups/GroupChatRoom.dart';
import 'package:Social/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class GroupDetails extends StatefulWidget {
  final dynamic participants;

  GroupDetails(this.participants);

  @override
  _GroupDetailsState createState() => _GroupDetailsState(this.participants);
}

class _GroupDetailsState extends State<GroupDetails> {
  dynamic participants;
  _GroupDetailsState(this.participants);
  var groupName = '';
  var _groupType = 1;
  var groupTypes = ['Masti Group', 'Working Group', 'Family Group'];
  bool _load = false;
  File image;

  List<Widget> getParticipants() {
    List<Widget> parti = [];

    participants.forEach((k, contact) => {
          parti.add(Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage('${contact['photoURL']}'),
                maxRadius: 24.0,
                minRadius: 20.0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50.0),
                  onTap: () => getImage(),
                ),
              ),
              Text(
                  '${contact['displayName'].toString().length > 15 ? '${contact['displayName'].toString().replaceAll('\n', ' ').replaceAll('\t', ' ').substring(0, 15)}..' : contact['displayName'].toString()}')
            ],
          ))
        });

    return parti;
  }

  getImage() async {
    // ignore: deprecated_member_use
    ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 70)
        .then((value) {
      setState(() {
        image = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        iconTheme: IconThemeData(color: forground, size: 30.0),
        title: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "New group",
                style: TextStyle(fontSize: 20.0, color: forground),
              ),
              Text(
                "Add subject",
                style: TextStyle(fontSize: 13.0, color: forground),
              ),
            ],
          ),
        ),
        backgroundColor: background,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Opacity(
              opacity: _load ? 0.25 : 1,
              child: Container(
                margin: EdgeInsets.only(top: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Column(
                        children: [
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Which type of group you want it to be?',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: forground,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          SizedBox(height: 5),
                          DropdownButton(
                              style: TextStyle(
                                  color: forground,
                                  fontWeight: FontWeight.w500),
                              value: _groupType,
                              items: [
                                DropdownMenuItem(
                                    child: Text("Masti Group"), value: 1),
                                DropdownMenuItem(
                                    child: Text("Working Group"), value: 2),
                                DropdownMenuItem(
                                    child: Text("Family Group"), value: 3),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _groupType = value;
                                });
                              }),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                    flex: 1,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      child: CircleAvatar(
                                        foregroundColor: Colors.black,
                                        backgroundImage: image == null
                                            ? NetworkImage(
                                                'https://firebasestorage.googleapis.com/v0/b/social-2c1f3.appspot.com/o/DummyImage%2Fdummy.jpg?alt=media&token=ed596480-73b0-4269-ada7-9e2c207df683')
                                            : FileImage(image),
                                        maxRadius: 24.0,
                                        minRadius: 20.0,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          onTap: () => getImage(),
                                          child: Center(
                                            child: Opacity(
                                                opacity: 0.8,
                                                child: Container(
                                                  color: Colors.transparent,
                                                  child: Icon(
                                                    Icons.camera_enhance,
                                                    color: forground,
                                                    size: 18,
                                                  ),
                                                )),
                                          ),
                                        ),
                                      ),
                                    )),
                                SizedBox(
                                  width: 15,
                                ),
                                Flexible(
                                    flex: 6,
                                    child: TextField(
                                      onChanged: (value) => {
                                        setState(() {
                                          groupName = value;
                                        })
                                      },
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: forground,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.8),
                                      maxLines: 1,
                                      maxLength: 30,
                                      autofocus: false,
                                      maxLengthEnforced: true,
                                      decoration: InputDecoration(
                                          hintText:
                                              'Enter a name for the group.',
                                          hintStyle: TextStyle(
                                            color: forground,
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          counterStyle: TextStyle(fontSize: 10),
                                          isDense: true,
                                          contentPadding:
                                              EdgeInsets.only(bottom: 2.0)),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: Container(
                      padding: EdgeInsets.all(20),
                      color: currentLine,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Participants : ${participants.length}'),
                          SizedBox(height: 20),
                          Expanded(
                            child: Container(
                              child: GridView.count(
                                crossAxisCount: 4,
                                childAspectRatio: 1.3,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 10,
                                children: getParticipants(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            ),
            if (!_load)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3 - 10,
                right: 10,
                child: Container(
                  margin: EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  child: FloatingActionButton(
                    onPressed: () {
                      if (groupName.length != 0) {
                        setState(() {
                          _load = true;
                        });

                        GroupsService()
                            .createGroup(participants, groupName, image,
                                groupTypes[_groupType - 1])
                            .then((value) {
                          setState(() {
                            _load = false;
                          });
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      GroupChatRoom(groupID: value)),
                              (Route<dynamic> route) {
                            return route.settings.name == '/';
                          });
                        });
                      } else {
                        Fluttertoast.showToast(
                          msg: "Please Fill Group Name!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.SNACKBAR,
                        );
                      }
                    },
                    backgroundColor: comment,
                    child: Icon(
                      Icons.check,
                      color: forground,
                      size: 30,
                    ),
                    tooltip: "Create Group",
                  ),
                ),
              ),
            if (_load)
              Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      backgroundColor: background,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Please Wait!!'),
                  Text('Group creation in progress'),
                ],
              ))
          ],
        ),
      ),
    );
  }
}
