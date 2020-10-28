import 'dart:io';
import 'package:Social/Groups.dart';
import 'package:Social/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditGroupDetails extends StatefulWidget {
  final dynamic groupId;
  final dynamic groupInfo;

  EditGroupDetails(this.groupId, this.groupInfo);

  @override
  _EditGroupDetailsState createState() =>
      _EditGroupDetailsState(this.groupId, this.groupInfo);
}

class _EditGroupDetailsState extends State<EditGroupDetails> {
  dynamic groupId;
  dynamic groupInfo;
  _EditGroupDetailsState(this.groupId, this.groupInfo);
  var groupName = '';
  var _groupType = 1;
  var groupTypes = ['Masti Group', 'Working Group', 'Family Group'];
  bool _load = false;
  File image;

  initState() {
    super.initState();

    groupName = groupInfo['groupName'];
    _groupType = groupTypes.indexOf(groupInfo['groupType']) + 1;
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
                "Edit details",
                style: TextStyle(fontSize: 20.0, color: forground),
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
                                                groupInfo['groupPhoto'])
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
                                    child: TextFormField(
                                      initialValue: groupInfo['groupName'],
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
                      if (groupName.length != 0 &&
                          (groupName != groupInfo['groupName'] ||
                              image != null ||
                              groupTypes[_groupType - 1] !=
                                  groupInfo['groupType'])) {
                        setState(() {
                          _load = true;
                        });

                        GroupsService()
                            .editGroupData(groupId, groupName, image,
                                groupTypes[_groupType - 1])
                            .then((value) {
                          setState(() {
                            _load = false;
                          });
                          print(value);
                          Navigator.pop(context, value);
                        });
                      } else {
                        Navigator.pop(context, null);
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
                  Text('Saving changes'),
                ],
              ))
          ],
        ),
      ),
    );
  }
}
