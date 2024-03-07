import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RadioBtn extends ChangeNotifier {
  String _selectvalue = "Income";
  String get selectvalue => _selectvalue;
  num totalInc = 0;
  int totalExp = 0;
  num get inc => totalInc;
  int get exp => totalExp;

  void valuechanged(val) {
    _selectvalue = val;
    print(_selectvalue);
    notifyListeners();
  }

  void addInc(int value) {
    totalInc = totalInc + value;
    print(totalInc);
    notifyListeners();
  }

  void addExp(int value) {
    totalExp = totalExp + value;
    print(totalExp);
    notifyListeners();
  }

  // void removeInc(int value) {
  //   totalInc = totalInc - value;
  //   notifyListeners();
  // }

  // void removeExp(int value) {
  //   totalExp = totalExp - value;
  //   notifyListeners();
  // }
}
