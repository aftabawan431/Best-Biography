import 'package:cloud_firestore/cloud_firestore.dart';

class DataClass{
 static List<BioModel> list=[];
 static addDBAnswer( BioModel bio){
   list.add(bio);
 }
 static Future<void> getAnswer()async{
   print('hre');
   final response=await FirebaseFirestore.instance.collection('biographies').get();
   DataClass.list=[];
   for(var item in response.docs){

     final type=item.data()['type']=='mySelf'?'Autobiography':'Biography';
     DataClass.addDBAnswer(BioModel(
       id: item.id,
       name: item.data()['name'],
       type:type,

     ));
   }


 }


}


class BioModel{
  final String id;
  final String name;
  final String type;
  BioModel({this.id,this.name,this.type});
}