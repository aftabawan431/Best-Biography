import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class YourBioWritesScreen extends StatefulWidget {
  final String id;
  YourBioWritesScreen(this.id);

  @override
  _YourBioWritesScreenState createState() => _YourBioWritesScreenState();
}


class _YourBioWritesScreenState extends State<YourBioWritesScreen> {
  var questions;
  File _answerImg;
TextEditingController _updateAnswerController=new TextEditingController();
  List<Model2> list=[];
  bool _loading=true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
getYourBioData();

  }


  getYourBioData()async{
    final response=await FirebaseFirestore.instance.collection('biographies').doc(widget.id).get();
print(response.data()['questions'][0]['question']);
    // questions=response.data()['questions'].map((e)=>e['question']).toList();
  var counter=0;
  for(var item in response.data()['answers']){
  list.add(Model2(
    id: item['id'],
  ifImg: item['ifImg'],
  imgUrl: item['imgUrl'],
  answer: item['answer'],
    imgKey: item['imgKey'],
    question:response.data()['questions'][counter]['question']
  ));
  counter++;
  }
    setState(() {
      _loading=false;
    });

  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Your Writes"),
            backgroundColor: Color(0xff25bcbb),
          ),
            body:_loading?Center(child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff25bcbb)),

            )): Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(

                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...list.map((e){
                        var answer="";
                          if(e.answer.length>0){


                        if(e.answer[e.answer.length-1]!='.'){
                          answer=e.answer+'. ';
                        }else{
                          answer=e.answer;
                        }
                          }
                        if(e.ifImg){

                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                            margin: EdgeInsets.symmetric(vertical: 5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                border:Border.all(
                                    width: 1.0,
                                    color: Colors.grey.withOpacity(.3)
                                )
                            ),
                            child: Column(
                            children: [
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text("Q: ${e.question}",style: TextStyle(fontSize: 25),)),
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(answer,style: TextStyle(fontSize: 20),)),
                              Container(
                                  height: 200,
                                  width: double.infinity,
                                  child:  CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: e.imgUrl,
                                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                                        CircularProgressIndicator(value: downloadProgress.progress,
                                          strokeWidth: 2.0,
                                          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff25bcbb)),

                                        ),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                  // Image.network(e.imgUrl,fit: BoxFit.contain,)
                              ),
                              ElevatedButton(onPressed:(){
                                editAnswer(e.id);
                              }, child:Text('edit'),
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color(0xff25bcbb)),
                                ),)

                            ],),
                          );
                        }else{
                          return Container(

                            margin: EdgeInsets.symmetric(vertical: 5),
                            padding: EdgeInsets.all(10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                border:Border.all(
                                    width: 1.0,
                                    color: Colors.grey.withOpacity(.3)
                                )
                            ),
                            child: Column(
                              children: [
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text("Q: ${e.question}",style: TextStyle(fontSize: 23),)),
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text("A: ${answer}",style: TextStyle(fontSize: 20,color: Colors.black54),)),
                                ElevatedButton(onPressed:(){
                                  editAnswer(e.id);
                                }, child:Text('edit'),
                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color(0xff25bcbb)),
                                ),)

                              ],
                            ),
                          );
                        }
                      }).toList(),
                    ],
                  ),
                ),
              ),
            )
        ),
    );
  }


  void showBox(BuildContext context,int id) async{
    var item=list.firstWhere((element) => element.id==id);

    _updateAnswerController.text=item.answer;
  final response= await showDialog(
        context: context,
        builder: (BuildContext context) {
           return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)

            ),
            elevation: 0,
            backgroundColor: Colors.white,
            child:Container(
              
              padding: EdgeInsets.all(20),
              width: 300,
              height: 300,
              child: Column(
                children: [
              TextField(
                controller: _updateAnswerController,

              ) ,
                  TextButton(onPressed: ()async{
                   await getImage();
                  }, child: Text("Get image"),),
                  if(item.ifImg)
                  TextButton(onPressed: (){

                    removeImage(item.id);
                  },child: Text("Remove Image"),),


                  TextButton(onPressed: ()async{
                    Navigator.of(context).pop(true);//update button



                  }, child: Text("Update"))
                ],
              ),

            ),
          );
        });
   if(response){
    update(item.id);
   }else{
     print("not update");
   }
  }

  editAnswer(int id){
    showBox(context,id);




  }


  update(id)async{
    var item=list.firstWhere((element) => element.id==id);
    var imgUrl=item.imgUrl;
    int imgKey=item.imgKey;
    var imgImg=item.ifImg;

    if(_answerImg!=null){
      var key=DateTime.now().millisecondsSinceEpoch;


      var storage=FirebaseStorage.instance.ref('images/$key');


      if(item.ifImg==true){
        var deleteRef=FirebaseStorage.instance.ref('images/${item.imgKey}');
        await deleteRef.delete();

      }
      await storage.putFile(_answerImg);
      imgUrl=await storage.getDownloadURL();
      imgKey=key;
      imgImg=true;

    }






    setState(() {
      list=list.map((e) {
        if(e.id==id){
          return Model2(
              id: item.id,
              answer: _updateAnswerController.text,
              ifImg: imgImg,
              imgUrl: imgUrl,
            imgKey:imgKey,
            question: item.question,
          );
        }else{
          return e;
        }
      }).toList();


    });
var data=list.map((e)=>{
  "id": e.id,
  "answer": e.answer,
  "ifImg": e.ifImg,
  "imgUrl": e.imgUrl,
  "imgKey":e.imgKey
}).toList();
    await FirebaseFirestore.instance.collection('biographies').doc(widget.id).update({
      "answers":data
    });

  }

  removeImage(id)async{
    var item=list.firstWhere((element) => element.id==id);
    var deleteRef=FirebaseStorage.instance.ref('images/${item.imgKey}');
    await deleteRef.delete();
    item.ifImg=false;
    item.imgUrl=null;
    item.imgKey=null;
    setState(() {
      list=list.map((e) {
        if(e.id==id){
          return Model2(
              id: item.id,
              answer: item.answer,
              ifImg: false,
              imgUrl: null
          );
        }else{
          return e;
        }
      }).toList();


    });
    var data=list.map((e)=>{
      "id": e.id,
      "answer": e.answer,
      "ifImg": e.ifImg,
      "imgUrl": e.imgUrl,
      "imgKey":e.imgKey
    }).toList();
    await FirebaseFirestore.instance.collection('biographies').doc(widget.id).update({
      "answers":data
    });
    Navigator.of(context).pop();


  }


  var _image;
  final picker = ImagePicker();

  Future getImage() async {
    var image = await  ImagePicker().getImage(
        source: ImageSource.gallery, imageQuality: 50
    );
    setState(() {
      if (image != null) {
        _answerImg =File(image.path);
      } else {
        print('No image selected.');
      }
    });
  }
}


class Model2{
  var  id;
  var  ifImg;
  var  imgUrl;
  var  answer;
  int imgKey;
  String question;
  Model2({this.imgUrl,this.ifImg,this.answer,this.id,this.imgKey,this.question});
}
