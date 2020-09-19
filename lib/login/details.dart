import 'dart:io';
import 'package:Social/User.dart';
import 'package:Social/home/home.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class EnterDetails extends StatefulWidget {
  @override
  _EnterDetailsState createState() => _EnterDetailsState();
}

class _EnterDetailsState extends State<EnterDetails> {
  var displayName = '';
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
    if (image != null) {
      StorageUploadTask storageUploadTask =
          ref.child('${FirebaseAuth.instance.currentUser.uid}').putFile(image);

      if (storageUploadTask.isSuccessful || storageUploadTask.isComplete) {
        final String url = await ref.getDownloadURL();
        print("The download URL is " + url);
      } else if (storageUploadTask.isInProgress) {
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

        print("Download URL " + photoURL);

        return photoURL;
      } else {
        print('Upload Failed');
        return 'https://firebasestorage.googleapis.com/v0/b/social-2c1f3.appspot.com/o/DummyImage%2Fdummy.jpg?alt=media&token=ed596480-73b0-4269-ada7-9e2c207df683';
      }
    }
    return 'https://firebasestorage.googleapis.com/v0/b/social-2c1f3.appspot.com/o/DummyImage%2Fdummy.jpg?alt=media&token=ed596480-73b0-4269-ada7-9e2c207df683';
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  addDetails() async {
    uploadPic().then((photoURL) {
      auth.currentUser
          .updateProfile(displayName: displayName, photoURL: photoURL)
          .then((value) {
        print('Data uploaded ${auth.currentUser.displayName} ');
        if (auth.currentUser != null) {
          UserService(
                  displayName: auth.currentUser.displayName,
                  creationTime: auth.currentUser.metadata.creationTime,
                  lastSignInTime: auth.currentUser.metadata.lastSignInTime,
                  phoneNumber: auth.currentUser.phoneNumber,
                  photoURL: auth.currentUser.photoURL,
                  uid: auth.currentUser.uid)
              .addUser();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  )
                ],
              ),
              SizedBox(height: 20),
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
                              ? NetworkImage(
                                  'https://firebasestorage.googleapis.com/v0/b/social-2c1f3.appspot.com/o/DummyImage%2Fdummy.jpg?alt=media&token=ed596480-73b0-4269-ada7-9e2c207df683')
                              : FileImage(image),
                          maxRadius: 24.0,
                          minRadius: 20.0,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50.0),
                            onTap: () => getImage(),
                            child: Center(
                              child: Opacity(
                                  opacity: 0.3,
                                  child: Container(
                                    color: Colors.white54,
                                    child: Icon(Icons.camera_enhance),
                                  )),
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
                              displayName = value;
                            })
                          },
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8),
                          maxLines: 1,
                          autofocus: true,
                          decoration: InputDecoration(
                              counterText: '',
                              hintText: 'Your Name to display.',
                              hintStyle: TextStyle(
                                  color: Colors.black12,
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: 1.0),
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
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 1.0),
                      ),
                      disabledColor: Colors.black26,
                      disabledTextColor: Colors.white54,
                      disabledElevation: 0.0,
                      color: Colors.black,
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
