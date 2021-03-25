import 'package:biography1/HomePage.dart';
import 'package:biography1/see%20your%20writes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'HomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'DataProvider.dart';
import 'Login_Screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:biography1/answer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());

}

class MyApp extends StatefulWidget {


  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white
      ),
      home: HomeScreen(),
      routes: {
        '/a':(ctx)=>LoginScreen(),
        '/b':(ctx)=>HomePage(),
        '/c':(ctx)=>SeeYourWrites(),
      },
    );
  }
}
