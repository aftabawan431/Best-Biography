import 'package:flutter/widgets.dart';

class DataProvider extends ChangeNotifier{
int _value=0;

get getValue{
  return _value;
}
void setValue(){
  _value++;
  notifyListeners();
}




}