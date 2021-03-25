
import 'dart:io';
import 'package:biography1/DataClass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';

class AnswerModel {
  final File img;
  final bool ifImg;
  final String answer;
  AnswerModel({this.img, this.answer, this.ifImg});
}

class Answers{
  static List<AnswerModel> answers = [];


     static void add(AnswerModel answer) {
      answers.add(answer);

    }
    static Future<void> uploadAnswer(String docId,int totalLength)async{
       var key=DateTime.now().millisecondsSinceEpoch;
       print(answers.length);
       var docRef = FirebaseFirestore.instance.collection('biographies').doc(
           docId);
       for(var item in answers) {
         print(item.img);
         var storage = FirebaseStorage.instance.ref('images/$key');
         var imgUrl = null;
         var imgKey = null;
         if (item.ifImg == true) {
           await storage.putFile(item.img);
           imgUrl = await storage.getDownloadURL();
           imgKey = key;
           print(imgUrl);
         }

         await docRef.update({
           "answers": FieldValue.arrayUnion([
             {
               "id": DateTime
                   .now()
                   .millisecondsSinceEpoch,
               "answer": item.answer,
               "ifImg": item.ifImg,
               "imgUrl": imgUrl,
               "imgKey": imgKey
             }
           ])
         });


       }
       for(int i=answers.length;i<totalLength;i++){
         await docRef.update({
           "answers":FieldValue.arrayUnion([
             {
               "id":DateTime.now().millisecondsSinceEpoch,
               "answer":"",
               "ifImg":false,
               "imgUrl":null,
               "imgKey":null
             }
           ])
         });
       }
       await DataClass.getAnswer();

    }

}
