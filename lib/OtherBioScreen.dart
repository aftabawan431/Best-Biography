import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

class OtherBioScreen extends StatefulWidget {
  final String id;
  OtherBioScreen(this.id);

  @override
  _OtherBioScreenState createState() => _OtherBioScreenState();
}

class _OtherBioScreenState extends State<OtherBioScreen> {
bool showQuestion=false;
  List<Model1> list=[];
  bool _loading=true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBioData();


  }


  getBioData()async{
    final response=await FirebaseFirestore.instance.collection('biographies').doc(widget.id).get();
   print(response.data()['answers'].length);
   for(var i=0;i<response.data()['answers'].length;i++){
       list.add(Model1(
         ifImg: response.data()['answers'][i]['ifImg'],
         imgUrl: response.data()['answers'][i]['imgUrl'],
         answer:  response.data()['answers'][i]['answer'],
         question:  response.data()['questions'][i]['question'],

       ));
   }
    //
    // for(var item in response.data()['answers']){
    //   list.add(Model1(
    //     ifImg: item['ifImg'],
    //     imgUrl: item['imgUrl'],
    //     answer: item['answer'],
    //     question: ""
    //
    //   ));
    // }
    // for(var item in response.data()['questions']){
    //   list.add(Model1(
    //       ifImg: item,
    //       imgUrl: item['imgUrl'],
    //       answer: item['answer'],
    //       question: ""
    //
    //   ));
    // }

    setState(() {
      _loading=false;
    });


  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:_loading?Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff25bcbb)),
          ),
        ): Padding(
          padding: EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            ElevatedButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color(0xff25bcbb) )),

        onPressed: (){

            setState(() {
              showQuestion=!showQuestion;
            });
        }, child: Text(showQuestion?"Biography ?":"Interview ?")),
                Wrap(
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

                   return Column(

                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       if(showQuestion)
                        Text("Q:${e.question}",style: TextStyle(fontSize: 25,color: Color(0xff25bcbb)),),
                       Text(answer,style: TextStyle(fontSize: 25),),
                       Container(
                           height: 200,
                           width: double.infinity,
                           child:
                           CachedNetworkImage(
                             fit: BoxFit.contain,

                             imageUrl: e.imgUrl,
                             progressIndicatorBuilder: (context, url, downloadProgress) =>
                                 SizedBox(
                                   height: 300.0,
                                   width: 300.0,
                                   child: CircularProgressIndicator(value: downloadProgress.progress,
                                     strokeWidth: 2.0,
                                     valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff25bcbb)),
                   ),
                                 ),
                             errorWidget: (context, url, error) => Icon(Icons.error),
                           ),
                   //         Image.network(e.imgUrl,fit: BoxFit.contain,)
                       )
                     ],
                   );
                 }else{
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(showQuestion&&answer.length>0)
                      Text('Q${e.question.length}:${e.question}',style: TextStyle(fontSize: 25,color: Color(0xff25bcbb)),),
                      Text(answer,style: TextStyle(fontSize: 25)),
                    ],
                  );
                 }
                 }).toList()
                  ],
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}

class Model1{
  final String question;
final bool ifImg;
final String imgUrl;
final String answer;
Model1({this.imgUrl,this.ifImg,this.answer,this.question});
}
