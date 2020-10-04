import 'dart:io';
import 'package:Social/User.dart';
import 'package:Social/home/home.dart';
import 'package:Social/theme/theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class EnterDetails extends StatefulWidget {
  @override
  _EnterDetailsState createState() => _EnterDetailsState();
}

class _EnterDetailsState extends State<EnterDetails> {
  var displayName = FirebaseAuth.instance.currentUser.displayName != null
      ? FirebaseAuth.instance.currentUser.displayName
      : '';
  File image;

  getImage() async {
    // ignore: deprecated_member_use
    ImagePicker.pickImage(source: ImageSource.gallery).then((value) {
      setState(() {
        image = value;
      });
    });
  }

  Future<String> uploadPic() async {
    FirebaseStorage _storage = FirebaseStorage.instance;

    //Create a reference to the location you want to upload to in firebase
    StorageReference ref = _storage.ref().child("ProfilePics/");
    //Upload the file to firebase
    StorageUploadTask storageUploadTask =
        ref.child('${FirebaseAuth.instance.currentUser.uid}').putFile(image);

    // if (storageUploadTask.isSuccessful || storageUploadTask.isComplete) {
    //   final String url = await ref.getDownloadURL();
    //   print("The download URL is " + url);
    // } else if (storageUploadTask.isInProgress) {
      storageUploadTask.events.listen((event) {
        double percentage = 100 *
            (event.snapshot.bytesTransferred.toDouble() /
                event.snapshot.totalByteCount.toDouble());
        print("THe percentage " + percentage.toString());
      });

      StorageTaskSnapshot storageTaskSnapshot =
          await storageUploadTask.onComplete;
      var photoURL =
          (await storageTaskSnapshot.ref.getDownloadURL()).toString();

      return photoURL;
    // }
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  addDetails() async {
    var token = await FirebaseMessaging().getToken();
    print(token);
    if (image != null) {
      uploadPic().then((photoURL) {
        auth.currentUser
            .updateProfile(displayName: displayName, photoURL: photoURL)
            .then((value) {
          print(
              'Data uploaded ${auth.currentUser.displayName} , ${auth.currentUser.photoURL}');
          if (auth.currentUser != null) {
            UserService(
                    displayName: auth.currentUser.displayName,
                    creationTime: auth.currentUser.metadata.creationTime,
                    lastSignInTime: auth.currentUser.metadata.lastSignInTime,
                    phoneNumber: auth.currentUser.phoneNumber,
                    photoURL: auth.currentUser.photoURL,
                    pushNotificationToken: token,
                    uid: auth.currentUser.uid)
                .addUser();
          }
        });
      });
    } else {
      auth.currentUser.updateProfile(displayName: displayName).then((value) {
        print('Data uploaded ${auth.currentUser.displayName} ');
        if (auth.currentUser != null) {
          UserService(
                  displayName: auth.currentUser.displayName,
                  creationTime: auth.currentUser.metadata.creationTime,
                  lastSignInTime: auth.currentUser.metadata.lastSignInTime,
                  phoneNumber: auth.currentUser.phoneNumber,
                  photoURL: auth.currentUser.photoURL,
                  pushNotificationToken: token,
                  uid: auth.currentUser.uid)
              .addUser();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Social',
                      style: TextStyle(
                          color: forground,
                          fontSize: 45,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Set Your Display Name',
                    style: TextStyle(
                        fontSize: 20,
                        color: forground,
                        fontWeight: FontWeight.w700),
                  )
                ],
              ),
              SizedBox(height: 30),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 30.0),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                        flex: 1,
                        child: CircleAvatar(
                          foregroundColor: Colors.black,
                          backgroundImage: image == null
                              ? NetworkImage(FirebaseAuth
                                          .instance.currentUser.photoURL ==
                                      null
                                  ? 'https://firebasestorage.googleapis.com/v0/b/social-2c1f3.appspot.com/o/DummyImage%2Fdummy.jpg?alt=media&token=ed596480-73b0-4269-ada7-9e2c207df683'
                                  : FirebaseAuth.instance.currentUser.photoURL)
                              : FileImage(image),
                          maxRadius: 24.0,
                          minRadius: 20.0,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50.0),
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
                        )),
                    SizedBox(
                      width: 15,
                    ),
                    Flexible(
                        flex: 6,
                        child: TextFormField(
                          onChanged: (value) => {
                            setState(() {
                              displayName = value;
                            })
                          },
                          initialValue: FirebaseAuth
                                      .instance.currentUser.displayName !=
                                  null
                              ? FirebaseAuth.instance.currentUser.displayName
                              : '',
                          style: TextStyle(
                              fontSize: 18,
                              color: forground,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8),
                          maxLines: 1,
                          autofocus: true,
                          decoration: InputDecoration(
                              counterText: '',
                              hintText: 'Your Name to display.',
                              hintStyle: TextStyle(
                                color: forground,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: 2.0)),
                        )),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 50,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      onPressed: (displayName.length != 0)
                          ? () {
                              addDetails();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyHomePage(),
                                  ));
                            }
                          : null,
                      child: Text(
                        'Next',
                        style: TextStyle(
                            color: forground,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            letterSpacing: 1.0),
                      ),
                      disabledColor: currentLine,
                      disabledTextColor: background,
                      disabledElevation: 0.0,
                      color: red,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
