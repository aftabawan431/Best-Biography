
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:biography1/FadeAnimation.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin{
  bool hasConnection = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    DataConnectionChecker().onStatusChange.listen((status) {
      setState(() {
        switch(status){
          case DataConnectionStatus.connected:

            setState(() {
              hasConnection = true;
            });
            print('connection');
            break;
          case DataConnectionStatus.disconnected:

            print('no connection');

            break;
        }
      });
    });

  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF1a203d),
        body:!hasConnection?Center(child: Text("No network",style: TextStyle(color: Colors.white,fontSize: 50),)):Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/96.png',
              height: 250,
            ),
            SizedBox(
              height: 20,
            ),
            FadeAnimation(2, Text(
              'Welcome to Generations',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),),
            SizedBox(height: 20),
            FadeAnimation(2.5,Text(
              'A one-stop portal for you to see the latest Biographies',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),),
            SizedBox(
              height: 30,
            ),
            //LoginScreen
            FadeAnimation(3, MaterialButton(

              elevation: 0,
              height: 50,
              onPressed: ()async {
                final user=await FirebaseAuth.instance.currentUser;
                if(user!=null){
                  Navigator.pushReplacementNamed(context, '/b');
                }else{

                  Navigator.of(context).popAndPushNamed('/a');
                }

                // Navigator.of(context).maybePop(MaterialPageRoute(builder: (ctx)=>LoginScreen()));
              },
              color: Colors.green,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Get Started',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  Icon(Icons.arrow_forward_ios)
                ],
              ),
              textColor: Colors.white,
            ),),
          ],
        ),
      ),
    );
  }
}
