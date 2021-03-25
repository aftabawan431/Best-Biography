
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
    Questions(id: 'mySelf',
      questionsList: [
    Question(question:'What is your Name?'),
        Question(question:'What is your age?'),
        Question(question:'What is your father name?'),
        Question(question:'What is your current status?'),
        Question(question:'How old are You?')

      ],
    ),
  Questions(id: 'herSelf',questionsList: [
    Question(question:'What is her Name?'),
    Question(question:'What is her age?'),
    Question(question:'What is her father name?'),
    Question(question:'What is her current status?'),
    Question(question:'How old is she?')
  ]),
    Questions(id: 'himSelf',questionsList: [
      Question(question:'What is his Name?'),
      Question(question:'What is his age?'),
      Question(question:'What is his father name?'),
      Question(question:'What is his current status?'),
      Question(question:'How old is He?')
    ]),
  ];
   List<Question> getdataList(String id){
        print("aftab $id");
        final newList=_dataList.firstWhere((el)=>el.id==id).questionsList;
         return newList;
      }
}