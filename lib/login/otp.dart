import 'package:Social/login/details.dart';
import 'package:Social/login/enter.dart';
import 'package:Social/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../User.dart';

class OtpLogin extends StatefulWidget {
  final String mobNumber;
  final String verificationId;
  final int resendToken;
  OtpLogin(
      {Key key,
      @required this.mobNumber,
      @required this.verificationId,
      @required this.resendToken})
      : super(key: key);
  @override
  _OtpLoginState createState() =>
      _OtpLoginState(mobNumber, verificationId, resendToken);
}

class _OtpLoginState extends State<OtpLogin> {
  String mobNumber;
  String verificationId;
  int resendToken;
  bool showProgressBar = false;

  _OtpLoginState(this.mobNumber, this.verificationId, this.resendToken);

  Future<void> checkOTP() async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: otp.join());

    await FirebaseAuth.instance
        .signInWithCredential(phoneAuthCredential)
        .then((value) {
      FirebaseAuth auth = FirebaseAuth.instance;
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EnterDetails()),
      );
    }).catchError((onError) {
      setState(() {
        showProgressBar = false;
      });
      Fluttertoast.showToast(
        msg: "Opps! You entered a wrong OTP.Please check it again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
      );
    });
  }

  var visited = false;
  List<String> otp = new List(6);

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
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter OTP',
                    style: TextStyle(
                        fontSize: 18,
                        color: forground,
                        fontWeight: FontWeight.w700),
                  )
                ],
              ),
              SizedBox(
                height: 13,
              ),
              Container(
                  child: Column(
                children: [
                  Text(
                    'Enter the 4 digit verification code sent to ',
                    style: TextStyle(
                      fontSize: 13,
                      color: forground,
                    ),
                  ),
                  Text(
                    'your registered mobile number',
                    style: TextStyle(
                      fontSize: 13,
                      color: forground,
                    ),
                  )
                ],
              )),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+91 $mobNumber is not your number?  ',
                    style: TextStyle(
                        fontSize: 15,
                        color: forground,
                        fontWeight: FontWeight.w500),
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FirstLogin(),
                            ));
                      },
                      child: Text(
                        'Edit',
                        style: TextStyle(
                            color: orange,
                            fontWeight: FontWeight.w700,
                            fontSize: 15),
                      ))
                ],
              ),
              SizedBox(height: 20),
              if (showProgressBar)
                Container(
                    padding: const EdgeInsets.only(top: 10.0),
                    margin: const EdgeInsets.only(top: 20.0),
                    child: CircularProgressIndicator()),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 30.0),
                width: MediaQuery.of(context).size.width * 0.7,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                        flex: 2,
                        child: TextField(
                            onChanged: (value) => {
                                  setState(() {
                                    if (value.length == 1) {
                                      FocusScope.of(context).nextFocus();
                                    }
                                    otp[0] = value;
                                  })
                                },
                            autofocus: true,
                            style: TextStyle(fontSize: 17),
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                counterText: '',
                                isDense: true,
                                contentPadding: EdgeInsets.only(bottom: 2.0)))),
                    SizedBox(
                      width: 12,
                    ),
                    Flexible(
                        flex: 2,
                        child: TextField(
                            onChanged: (value) => {
                                  setState(() {
                                    if (value.length == 1) {
                                      FocusScope.of(context).nextFocus();
                                    }
                                    otp[1] = value;
                                  })
                                },
                            // autofocus: visited[0],
                            style: TextStyle(fontSize: 17),
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                counterText: '',
                                isDense: true,
                                contentPadding: EdgeInsets.only(bottom: 2.0)))),
                    SizedBox(
                      width: 12,
                    ),
                    Flexible(
                        flex: 2,
                        child: TextField(
                            onChanged: (value) => {
                                  setState(() {
                                    if (value.length == 1) {
                                      FocusScope.of(context).nextFocus();
                                    }
                                    otp[2] = value;
                                  })
                                },
                            // autofocus: visited[0],
                            style: TextStyle(fontSize: 17),
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                counterText: '',
                                isDense: true,
                                contentPadding: EdgeInsets.only(bottom: 2.0)))),
                    SizedBox(
                      width: 12,
                    ),
                    Flexible(
                        flex: 2,
                        child: TextField(
                            onChanged: (value) => {
                                  setState(() {
                                    if (value.length == 1) {
                                      FocusScope.of(context).nextFocus();
                                    }
                                    otp[3] = value;
                                  })
                                },
                            // autofocus: visited[0],
                            style: TextStyle(fontSize: 17),
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                counterText: '',
                                isDense: true,
                                contentPadding: EdgeInsets.only(bottom: 2.0)))),
                    SizedBox(
                      width: 12,
                    ),
                    Flexible(
                        flex: 2,
                        child: TextField(
                            onChanged: (value) => {
                                  setState(() {
                                    if (value.length == 1) {
                                      FocusScope.of(context).nextFocus();
                                    }
                                    otp[4] = value;
                                  })
                                },
                            // autofocus: visited[0],
                            style: TextStyle(fontSize: 17),
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                counterText: '',
                                isDense: true,
                                contentPadding: EdgeInsets.only(bottom: 2.0)))),
                    SizedBox(
                      width: 12,
                    ),
                    Flexible(
                        flex: 2,
                        child: TextField(
                            onChanged: (value) => {
                                  setState(() {
                                    if (value.length == 1) {
                                      FocusScope.of(context).unfocus();
                                    }
                                    otp[5] = value;
                                  })
                                },
                            // autofocus: visited[0],
                            style: TextStyle(fontSize: 17),
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                counterText: '',
                                isDense: true,
                                contentPadding: EdgeInsets.only(bottom: 2.0)))),
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
                      onPressed: (otp.join().length == 6)
                          ? () {
                              setState(() {
                                showProgressBar = true;
                              });
                              checkOTP();
                            }
                          : null,
                      child: Text(
                        'Verify',
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
