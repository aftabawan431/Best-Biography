import 'package:biography1/DataClass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:biography1/yourBioWritesScreen.dart';
import 'package:confirm_dialog/confirm_dialog.dart';


class SeeYourWrites extends StatefulWidget {
  @override
  _SeeYourWritesState createState() => _SeeYourWritesState();
}

class _SeeYourWritesState extends State<SeeYourWrites> {

  List<BioModel> list=[];
  final Color primaryColor = Color(0xff18203d);
  final Color secondaryColor = Color(0xff232c51);

  final Color logoGreen = Color(0xff25bcbb);
  bool _loading=true;
@override
  void initState() {
    // TODO: implement initState
    super.initState();

    getData();
  }

  getData()async{
setState(() {
  list=[];
});

  final user=await FirebaseAuth.instance.currentUser;
  final response=await FirebaseFirestore.instance.collection('biographies').where('userId',isEqualTo: user.uid).get();
  print(response.docs);
  for(var item in response.docs){

    final type=item.data()['type']=='mySelf'?'Autobiography':'Biography';

  list.add(BioModel(
      id: item.id,
      name: item.data()['name'],
      type: type
  ));



  }
setState(() {
  _loading=false;
});

  }

  @override
  Widget build(BuildContext context) {
    return _loading?Center(child: CircularProgressIndicator(
      backgroundColor: Colors.white,
      valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff25bcbb)),

    )):Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Welcome User"),
        backgroundColor:  logoGreen,
      ),
      body: Container(
        margin: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            Center(child: Text('Your Writes',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w700),)),
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: list.length,
                itemBuilder: (BuildContext context,int index){
                  return Card(
                    child: InkWell(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>YourBioWritesScreen(list[index].id)));
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        width: double.infinity,
                        height: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Name : ${list[index].name}"),
                            Text("Type : ${list[index].type}"),
                            TextButton(onPressed: ()async{

                              if (await confirm(context)) {

                                final docRef=await FirebaseFirestore.instance.collection('biographies').doc(list[index].id);
                                final data=await docRef.get();

                                for(var item in data.data()['answers']){
                                  if(item['ifImg']==true){

                                    var deleteRef=FirebaseStorage.instance.ref('images/${item['imgKey']}');
                                    await deleteRef.delete();
                                    print('deleted');
                                  }
                                }
                                await docRef.delete();
                                setState(() {
                                  list=list.map((e) {
                                    if(e.id!=list[index].id){
                                      return e;
                                    }
                                  }).toList();
                                });
                                getData();


                              }

                            }, child: Text("Delete",style:TextStyle(color: Colors.red)))

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
    );
  }
}

