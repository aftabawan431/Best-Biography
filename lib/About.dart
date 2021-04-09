import 'package:biography1/answer.dart';
import 'package:biography1/payment screen.dart';
import 'Paypal/PaypalPayment.dart';
import 'QuestionsScreen.dart';
import 'package:flutter/material.dart';
enum SingingCharacter { yourself, herself,himself }

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  TextEditingController userNameController = TextEditingController();
  bool userNameValidate = false;
  bool _isError=false;
  bool validateTextField(String userInput) {
    if (userInput.isEmpty) {
      setState(() {
        userNameValidate = true;
      });
      return false;
    }
    setState(() {
      userNameValidate = false;
    });
    return true;
  }

  SingingCharacter _character = SingingCharacter.yourself;
  TextEditingController _nameController = new TextEditingController();
  final Color primaryColor = Color(0xff18203d);
  final Color secondaryColor = Color(0xff232c51);

  final Color logoGreen = Color(0xff25bcbb);


    @override
    Widget build(BuildContext context) {
      return Scaffold(
          resizeToAvoidBottomInset: false,

        appBar: AppBar(
          backgroundColor: Color(0xff25bcbb),
            title:
            Text('About')),
        backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(top: 50,left: 20,right: 20),
            child: Center(
              child: Container(
                padding: EdgeInsets.only(top: 10),
                height: 450,
                width: 400,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),]),
                child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Text(('Please Choose'),style: TextStyle(fontSize: 20,fontWeight: FontWeight.w800),),
                 YouOrSomeone((SingingCharacter value){
                   setState(() {
                     _character=value;
                   });

                 }),
                    // Text(('Gender'),style: TextStyle(fontSize: 20,fontWeight: FontWeight.w800),),
                    // Gender(),
                    Text(('Enter name'),style: TextStyle(fontSize: 20,fontWeight: FontWeight.w800),),
                TextField(
                  controller: _nameController ,

                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(fontSize: 20),
                      border: InputBorder.none,
                      hintText: 'Enter the Name',
                    errorText:_isError? "Please enter a name":null,

                  ),
                ),
                    SizedBox(height: 30,),

                    ElevatedButton(onPressed:(){
                      if(_nameController.text==""){
                        setState(() {
                          _isError=true;
                        });
                        return;
                      }
                      validateTextField(userNameController.text);
                      print(_character);
                      Answers.answers=[];

                      if(_character==SingingCharacter.herself){
                        Navigator.of(context).push(MaterialPageRoute(builder:(ctx)=> PaypalPayment(
                          onFinish: (number) async {

                            // payment done
                            print('order id: '+number);

                          },
                        ),));

                        // Navigator.of(context).push(MaterialPageRoute(builder:(ctx)=>QuestionsScreen("herSelf",_nameController.text)));
                       // print(completelist);
                        print("her self is selected");
                      }else if(_character==SingingCharacter.yourself){
                        Navigator.of(context).push(MaterialPageRoute(builder:(ctx)=>QuestionsScreen("mySelf",_nameController.text)));
                        // print(completelist);
                        print("your self is selected");

                      }else{

                        Navigator.of(context).push(MaterialPageRoute(builder:(ctx)=>QuestionsScreen("himSelf",_nameController.text)));
                        // print(completelist);
                        print("him self is selected");

                        // Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>QuestionsScreen("himself")));
                      }
                    },
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(logoGreen )),

                        child: Text('Next',)
                    )
                  ],
                ),
              ),
            ),
          )
      );
    }
  }


class YouOrSomeone extends StatefulWidget {

  final Function valueFunction;
  YouOrSomeone(this.valueFunction);

  @override
  _YouOrSomeoneState createState() => _YouOrSomeoneState();
}

class _YouOrSomeoneState extends State<YouOrSomeone> {
  SingingCharacter _character = SingingCharacter.yourself;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile<SingingCharacter>(
          title: const Text('yourself'),
          value: SingingCharacter.yourself,
          groupValue: _character,
          onChanged: (SingingCharacter value) {
            setState(() {
              _character = value;
              widget.valueFunction(_character);

            });
          },
        ),
        RadioListTile<SingingCharacter>(
          title: const Text('herself'),
          value: SingingCharacter.herself,
          groupValue: _character,
          onChanged: (SingingCharacter value) {
            setState(() {
              _character = value;
              widget.valueFunction(_character);
            });
          },
        ),
        RadioListTile<SingingCharacter>(
          title: const Text('himself'),
          value: SingingCharacter.himself,
          groupValue: _character,
          onChanged: (SingingCharacter value) {
            setState(() {
              _character = value;
              widget.valueFunction(_character);
            });
          },
        ),

      ],

    );
  }
}