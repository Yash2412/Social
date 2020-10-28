import 'package:Social/Groups.dart';
import 'package:Social/theme/theme.dart';
import 'package:flutter/material.dart';

class CreatePost extends StatefulWidget {
  final dynamic groupID;
  final dynamic selectedImage;
  CreatePost(this.groupID, this.selectedImage);
  @override
  _CreatePostState createState() =>
      _CreatePostState(this.groupID, this.selectedImage);
}

class _CreatePostState extends State<CreatePost> {
  dynamic groupID;
  var selectedImage;
  _CreatePostState(this.groupID, this.selectedImage);
  TextEditingController captionController = new TextEditingController();
  bool _load = false;

  showConfirmationAlert(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Discard Post"),
      content: Text("Would you discard this post?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure!'),
            content: Text('Do you want to discard this post?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          iconTheme: IconThemeData(color: forground, size: 30.0),
          title: Text('New post', style: TextStyle(color: forground)),
          backgroundColor: background,
          titleSpacing: 0,
          actions: [
            InkWell(
              onTap: () {
                setState(() {
                  _load = true;
                });
                GroupsService().addPost(groupID, {
                  'media': selectedImage,
                  'caption': captionController.text.toString(),
                }).then((value) {
                  setState(() {
                    _load = false;
                  });
                  Navigator.pop(context);
                });
              },
              child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                      alignment: Alignment.center,
                      child: Text('Share',
                          style: TextStyle(
                              color: comment,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)))),
            )
          ],
        ),
        body: Stack(
          children: [
            Opacity(
              opacity: _load ? 0.25 : 1,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(200),
                        image: new DecorationImage(
                            fit: BoxFit.cover,
                            // colorFilter: ColorFilter.mode(
                            //     Colors.black.withOpacity(0.8), BlendMode.dstATop),
                            image: MemoryImage(selectedImage)),
                      ),
                    ),
                    SizedBox(height: 30),
                    Divider(
                      height: 0,
                      thickness: 1.5,
                    ),
                    Container(
                      child: TextField(
                        controller: captionController,
                        maxLines: 100,
                        minLines: 1,
                        style: TextStyle(fontSize: 16),
                        onChanged: (value) {},
                        decoration: InputDecoration(
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            filled: true,
                            labelText: "Caption",
                            labelStyle: TextStyle(
                              color: comment,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 30.0),
                            fillColor: Colors.transparent),
                      ),
                    ),
                    Divider(
                      height: 0,
                      thickness: 1.5,
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Hide from '),
                          Switch(
                              value: true,
                              onChanged: (val) {
                                print("object");
                              })
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Hide from '),
                          Switch(
                              value: true,
                              onChanged: (val) {
                                print("object");
                              })
                        ],
                      ),
                    ),
                  ],
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
                  Text('Post is uploading.'),
                ],
              ))
          ],
        ),
      ),
    );
  }
}
