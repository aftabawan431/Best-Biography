
class Question{
  final String question;
  Question({ this.question});

}

class Questions{
  List<Question> questionsList;
  final String id;
Questions({ this.questionsList, this.id});
}

class  QuestionsCollection{
   List<Questions> _dataList=[
    Questions(id: 'mySelf', questionsList: [],),
  Questions(id: 'herSelf',questionsList: []),
    Questions(id: 'himSelf',questionsList: []),
  ];
   List<Question> getdataList(String id){
        print("aftab $id");
        final newList=_dataList.firstWhere((el)=>el.id==id).questionsList;
         return newList;
      }
}