import 'package:Social/login/details.dart';
import 'package:Social/login/otp.dart';
import 'package:Social/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirstLogin extends StatefulWidget {
  @override
  _FirstLoginState createState() => _FirstLoginState();
}

class _FirstLoginState extends State<FirstLogin> {
  var mobNumber = '';
  bool showProgressBar = false;

  Future<void> verify(BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
      phoneNumber: '+91' + this.mobNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential).then((value) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EnterDetails(),
              ));
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.code);
        print(e.message);
        setState(() {
          showProgressBar = false;
        });

        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, int resendToken) async {
        print("codesent");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpLogin(
                  mobNumber: mobNumber,
                  verificationId: verificationId,
                  resendToken: resendToken),
            ));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-resolution timed out...
        print(verificationId);
      },
      timeout: Duration(seconds: 30),
    );
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
                          fontSize: 45,
                          letterSpacing: 0.2,
                          color: forground,
                          fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign Up',
                    style: TextStyle(
                        fontSize: 20,
                        color: forground,
                        fontWeight: FontWeight.w700),
                  )
                ],
              ),
              if (showProgressBar)
                Container(
                    padding: const EdgeInsets.only(top: 10.0),
                    margin: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator()),
              SizedBox(height: 50),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 30.0),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                        flex: 1,
                        child: TextField(
                            style: TextStyle(
                              fontSize: 17,
                              color: forground,
                            ),
                            maxLines: 1,
                            minLines: 1,
                            keyboardType: TextInputType.phone,
                            enabled: false,
                            controller: TextEditingController()..text = '+ 91',
                            decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.only(bottom: 2.0)))),
                    SizedBox(
                      width: 12,
                    ),
                    Flexible(
                        flex: 6,
                        child: TextField(
                          onChanged: (value) => {
                            setState(() {
                              mobNumber = value;
                            })
                          },
                          style: TextStyle(
                              fontSize: 17,
                              color: forground,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8),
                          maxLength: 10,
                          maxLines: 1,
                          autofocus: true,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              counterText: '',
                              hintText: 'Enter mobile number',
                              hintStyle: TextStyle(
                                  color: forground,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1.0),
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: 2.0)),
                        )),
                  ],
                ),
              ),
              SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 50,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      onPressed: (mobNumber.length == 10)
                          ? () {
                              setState(() {
                                showProgressBar = true;
                              });
                              verify(context);
                            }
                          : null,
                      child: Text(
                        'Next',
                        style: TextStyle(
                            color: forground,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
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
