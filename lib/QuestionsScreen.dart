import 'package:biography1/answer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Questions.dart';
import 'QuestionsHub.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:biography1/Widgets/customAlertDialoge.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:double_back_to_close/double_back_to_close.dart';

class QuestionsScreen extends StatefulWidget {
  final String id;
  final String name;
  QuestionsScreen(this.id, this.name);
  final Color primaryColor = Color(0xff18203d);
  final Color secondaryColor = Color(0xff232c51);
  final Color logoGreen = Color(0xff25bcbb);

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  List<dynamic> _questions = [];
  bool _loading = true;
  bool _publishLoading = false;
  bool _EndpublishLoading = false;
  User loggedInUser;
  File _answerImg;
  var _state = 0;
  var lastAddingState;
  File _lastImage=null;
  var _lastIfImage;
  var _lastAnswer = "";
  var _stateChanged = false;
  final Color logoGreen = Color(0xff25bcbb);
  bool disabler = false;

  final Color primaryColor = Color(0xff18203d);

  final Color secondaryColor = Color(0xff232c51);

  TextEditingController controller = new TextEditingController();
  QuestionsHub questionsHub = QuestionsHub();
  void resetAll() {
    setState(() {
      disabler = false;
    });
  }

  setQuestions() async {
    setState(() {
      QuestionsHub.questionsofHub = [];
      QuestionsHub.questionNo = 0;
    });

    final response = await FirebaseFirestore.instance
        .collection(widget.id)
        .orderBy("No")
        .get();
    for (var i in response.docs) {
      print(i.data());

      QuestionsHub.addQuestion(Question(question: i.data()['question']));
    }
    _questions = QuestionsHub.questionsofHub
        .map((e) => {"question": e.question})
        .toList();
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setQuestions();
  }

  var _image;
  final picker = ImagePicker();

  Future getImage() async {
    var image = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      if (image != null) {
        _answerImg = File(image.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController _emailControllerField = TextEditingController();
          return CustomAlertDialog(
            content: _loading
                ? SizedBox(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Color(0xff25bcbb)),
                    ),
                    height: 200,
                    width: 200,
                  )
                : Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: MediaQuery.of(context).size.height / 4.0,
                    color: Colors.white,
                    child: Column(
                      children: [
                        CircleAvatar(
                          child: Image.asset('assets/smile.png'),
                          radius: 50,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Center(
                            child: Text(
                          'Questions Ended',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )),
                        SizedBox(
                          height: 10,
                        ),
                        if (_EndpublishLoading)
                          CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Color(0xff25bcbb)),
                          ),
                        if (!_EndpublishLoading)
                          ElevatedButton(
                            child: Text('publish'),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        logoGreen)),
                            onPressed: _publish,
                          )
                      ],
                    )),
          );
        });
  }

  Future<void> _publish() async {
    setState(() {
      _publishLoading = true;
    });
    if (_answerImg != null || controller.text.length > 0) {
      if (_answerImg == null) {
        Answers.add(
            AnswerModel(answer: controller.text, ifImg: false, img: null));
      } else {
        Answers.add(
            AnswerModel(answer: controller.text, ifImg: true, img: _answerImg));
      }
    }
    final user = await FirebaseAuth.instance.currentUser;
    final docId = DateTime.now().millisecondsSinceEpoch.toString();
    await FirebaseFirestore.instance.collection('biographies').doc(docId).set({
      "userId": user.uid,
      "email": user.email,
      "createdAt": DateTime.now(),
      "type": widget.id,
      "name": widget.name,
      "answers": [],
      "questions": _questions
    });

    await Answers.uploadAnswer(docId, QuestionsHub.questionsofHub.length);
    print("done");
    setState(() {
      _publishLoading = false;
    });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }
  DateTime currentBackPressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'press again');
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: _loading
            ? Center(
                child: CircularProgressIndicator(
                valueColor:
                    new AlwaysStoppedAnimation<Color>(Color(0xff25bcbb)),
              ))
            : Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  backgroundColor: Color(0xff25bcbb),
                  title: Text('Questions Screen'),
                ),
                body: QuestionsHub.questionsofHub.length < 1
                    ? Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          height: 200,
                          width: 300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                  child: Text(
                                'There is no Question',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700),
                              )),
                              // TextButton(onPressed: (){}, child: Text('ok'))
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: logoGreen, // background

                                  onPrimary: Colors.white, // foreground
                                ),
                                child: Text('Ok'),
                              )
                            ],
                          ),
                        ),
                      )
                    : DoubleBack(
                  message: "Press again to exit",
                      child: Container(
                          color: Color(0xFFFAF9F6),

                          // color: primaryColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // if(_answerImg!=null)
                                //  Expanded(child: Image.file(_answerImg,fit: BoxFit.cover,)),
                                Expanded(
                                  flex: 1,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Question: ${QuestionsHub.getCurrentQuestion() + 1} of ${QuestionsHub.getTotalQuestion()}',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black),
                                            ),
                                            if (_publishLoading)
                                              CircularProgressIndicator(
                                                valueColor:
                                                    new AlwaysStoppedAnimation<
                                                        Color>(Color(0xff25bcbb)),
                                              ),
                                            if (!_publishLoading)
                                              ElevatedButton(
                                                  onPressed: _publish,
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                                  logoGreen)),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "Publish",
                                                        style: TextStyle(
                                                            color: Colors.white),
                                                      ),
                                                      Icon(Icons.publish,
                                                          color: Colors.white),
                                                    ],
                                                  )),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Wrap(
                                            children: [
                                              // Text('Qno:${QuestionsHub.getCurrentQuestion()+1}',style: TextStyle(fontSize: 20,color: Colors.white),),
                                              Text(
                                                QuestionsHub.getQuestionsText(),
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          color: Colors.transparent,
                                          child: Column(
                                            children: [
                                              TextField(
                                                controller: controller,
                                                maxLines: 15,
                                                minLines: 5,
                                                cursorColor: logoGreen,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20),
                                                decoration: InputDecoration(
                                                  border: new OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      const Radius.circular(10.0),
                                                    ),
                                                  ),
                                                  hintText: ('write your answer'),
                                                  hintStyle: TextStyle(
                                                      color: Colors.black54),

                                                  // focusedBorder: OutlineInputBorder(
                                                  //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                  //     borderSide: BorderSide(color: Colors.white)),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 10),
                                                  labelStyle: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15),
                                                ),
                                              ),
                                              if (_answerImg != null)
                                                Expanded(
                                                    child: Image.file(
                                                  _answerImg,
                                                  fit: BoxFit.contain,
                                                )),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                setState(() {


                                                  if (QuestionsHub.questionNo >
                                                      0) {
                                                    if (_stateChanged == false) {
                                                      _state = 1;
                                                      lastAddingState = QuestionsHub
                                                          .getCurrentQuestion();
                                                      _lastAnswer =
                                                          controller.text;
                                                      print("Last image configured");
                                                      _lastImage=_answerImg;
                                                      print(_answerImg);
                                                      // if (_answerImg == null) {
                                                      //   _lastIfImage = false;
                                                      // } else {
                                                      //   _lastIfImage = false;
                                                      //   _lastImage = _answerImg;
                                                      // }

                                                      _stateChanged = true;
                                                    }
                                                     _answerImg = null;

                                                    QuestionsHub
                                                        .previousQuestion();

                                                    controller.text = Answers
                                                        .answers[QuestionsHub
                                                            .getCurrentQuestion()]
                                                        .answer;
                                                    _answerImg = Answers
                                                        .answers[QuestionsHub
                                                            .getCurrentQuestion()]
                                                        .img;
                                                  }
                                                });
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(logoGreen),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.navigate_before_sharp,
                                                    color: Colors.yellow,
                                                  ),
                                                  Text(
                                                    " Previous",
                                                    style: TextStyle(
                                                        color: Colors.yellow),
                                                  ),
                                                ],
                                              )),
                                          ElevatedButton(
                                              onPressed: getImage,
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(logoGreen),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.image),
                                                  Text(" Image"),
                                                ],
                                              )),
                                          if (_EndpublishLoading)
                                            CircularProgressIndicator(
                                              valueColor:
                                                  new AlwaysStoppedAnimation<
                                                      Color>(Color(0xff25bcbb)),
                                            ),
                                          if (!_EndpublishLoading)
                                            ElevatedButton(
                                                onPressed:nextFunction,
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty.all<
                                                            Color>(logoGreen)),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Next ",
                                                      style: TextStyle(
                                                          color: Colors.yellow),
                                                    ),
                                                    Icon(
                                                      Icons.navigate_next,
                                                      color: Colors.yellow,
                                                    )
                                                  ],
                                                )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(onPressed: (){
                                  print("Last img is: $_lastImage");

                                }, child: Text("Test"))
                              ],
                            ),
                          ),
                        ),
                    ),
              ));
  }



  nextFunction(){
    if (_state == 1) {
      Answers.answers[QuestionsHub.questionNo].img=_answerImg;
      Answers.answers[QuestionsHub.questionNo].ifImg=_answerImg==null?null:true;
      Answers.answers[QuestionsHub.questionNo].answer=controller.text;

      setState(() {
        _answerImg = null;
        controller.text = "";
        if (disabler == false) {
          resetAll();
          if (QuestionsHub
              .getCurrentQuestion() ==
              QuestionsHub
                  .getTotalQuestion() -
                  1) {
            showAlertDialog(
                context);
          } else{





            if(QuestionsHub.questionNo+1==lastAddingState){
              _state=0;
              _stateChanged=false;
              _answerImg=_lastImage;
              controller.text=_lastAnswer;
            }

            QuestionsHub
                .nextQuestion();
            if(QuestionsHub.questionNo!=lastAddingState) {
              controller.text = Answers.answers[QuestionsHub.questionNo].answer;
              _answerImg = Answers.answers[QuestionsHub.questionNo].img;
            }

          }
        }
      });




    } else {
      if (_answerImg == null) {
        Answers.add(AnswerModel(
            answer: controller.text,
            ifImg: false,
            img: null));
      } else {
        Answers.add(AnswerModel(
            answer: controller.text,
            ifImg: true,
            img: _answerImg));
      }

      setState(() {
        _answerImg = null;
        controller.text = "";
        if (disabler == false) {
          resetAll();
          if (QuestionsHub
              .getCurrentQuestion() ==
              QuestionsHub
                  .getTotalQuestion() -
                  1) {
            showAlertDialog(
                context);
          } else
            QuestionsHub
                .nextQuestion();
        }
      });
    }
  }
}
