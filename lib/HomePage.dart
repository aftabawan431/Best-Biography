import 'package:biography1/DataClass.dart';
import 'package:biography1/OtherBioScreen.dart';
import 'package:biography1/see%20your%20writes.dart';
import 'package:flutter/material.dart';
import 'About.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
 bool order = false;
  bool _loading=true;

  final Color primaryColor = Color(0xff18203d);
  final Color secondaryColor = Color(0xff232c51);
  User loggedInUser;
  final _auth=FirebaseAuth.instance;

  final Color logoGreen = Color(0xff25bcbb);

  Future<void>  getCurrentUser() async{
    try{
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    }
    catch(e){
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getAnswers();
  }
  getAnswers()async{
  await DataClass.getAnswer();
    setState(() {
      _loading=false;
    });

  }


  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: logoGreen, // background
              onPrimary: Colors.white, // foreground
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: logoGreen, // background
              onPrimary: Colors.white, // foreground
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Biography"),
        backgroundColor:  logoGreen,
      ),
      drawer: Drawer(
        child: MainDrawer(),
      ),
      body:

      _loading?Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff25bcbb)),
        ),
      ):
      WillPopScope(
        onWillPop:() {
          if (_globalKey.currentState.isDrawerOpen) {
            Navigator.pop(context); // closes the drawer if opened
            return Future.value(false); // won't exit the app
          } else {
            return _onWillPop(); // exits the app
          }
        },
        child: RefreshIndicator(
          color: logoGreen,
          onRefresh: (){
            return Navigator.of(context).popAndPushNamed('/b');

          },
          child: Container(
            margin: EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color(0xFFFAF9F6),
            ),
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                Center(child: Text('Previous Writes',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w700),)),

                Expanded(
                  child: ListView.builder(
                    itemCount: DataClass.list.length,
                    itemBuilder: (BuildContext context,int index){
                      return Card(
                        child: InkWell(
                          onTap: (){
                            print(DataClass.list[index].id);
                            Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>OtherBioScreen(DataClass.list[index].id)));
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                            width: double.infinity,
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Name : ${DataClass.list[index].name}"),
                                Text("Type : ${DataClass.list[index].type}"),

                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final Color primaryColor = Color(0xff18203d);

  final Color secondaryColor = Color(0xff232c51);

  final Color logoGreen = Color(0xff25bcbb);

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();

  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        child: Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
              Image.asset('assets/96.png'),
              SizedBox(
                height: 5.0,
              ),
              Text(
                "Generations",
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                "Write your Words",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 40.0,
      ),
      ListTile(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>About()));

        },
        leading: Icon(
          Icons.person,
          color: Colors.black,
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded,color: Colors.black,size: 18,),
        title: Text("Write Biography"),
      ),

      ListTile(
        onTap: ()
        {
          Navigator.of(context).push(MaterialPageRoute(builder :(ctx)=>SeeYourWrites()));
        },
        leading: Icon(
          Icons.inbox,
          color: Colors.black,
        ),
        title: Text("See your Writes"),
        trailing: Icon(Icons.arrow_forward_ios_rounded,color: Colors.black,size: 18,),
      ),
      ListTile(
        onTap: () {

          _signOut();
          Navigator.of(context).pushReplacementNamed('/a');

        },
        leading: Icon(
          Icons.logout,
          color: Colors.black,
        ),
        title: Text("SignOut"),
        trailing: Icon(Icons.arrow_forward_ios_rounded,color: Colors.black,size: 18,),
      ),

    ]);
  }
}
