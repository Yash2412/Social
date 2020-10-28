import 'package:Social/home/home.dart';
import 'package:Social/login/details.dart';
import 'package:Social/login/enter.dart';
import 'package:Social/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of our application.

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  initState() {
    super.initState();

    setColor();
  }

  setColor() async {
    await FlutterStatusbarcolor.setStatusBarColor(background);
    await FlutterStatusbarcolor.setNavigationBarColor(background);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
  }

  isLogin() {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  isDisplayNameSet() {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser.displayName == null) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return MaterialApp(
            theme: ThemeData(
                brightness: Brightness.dark,
                primaryColor: forground,
                backgroundColor: background,
                fontFamily: 'Roboto'),
            debugShowCheckedModeBanner: false,
            title: 'Social',
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // Once complete, show our application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
              // routes: {
              //   '/home/AllContactsForGroup': (context) => AllContactsForGroup(),
              //   '/home/AllContactsForGroup/SetGroupDetails': (context) => (),

              // },
              theme: ThemeData(
                  brightness: Brightness.dark,
                  primaryColor: forground,
                  backgroundColor: background,
                  fontFamily: 'Roboto'),
              debugShowCheckedModeBanner: false,
              title: 'Social',
              home: isLogin()
                  ? (isDisplayNameSet() ? MyHomePage() : EnterDetails())
                  : FirstLogin());
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(
          theme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: forground,
              backgroundColor: background,
              fontFamily: 'Roboto'),
          debugShowCheckedModeBanner: false,
          title: 'Social',
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}
