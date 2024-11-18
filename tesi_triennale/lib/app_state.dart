import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String _a1a5 = 'A1-A5';
  String _categorie = 'categorie';
  String _conti = 'conti';
  String _progetti = 'progetti';

  CollectionReference get a1a5 => firestore.collection(_a1a5);
  CollectionReference get categorie => firestore.collection(_categorie);
  CollectionReference get conti => firestore.collection(_conti);
  CollectionReference get progetti => firestore.collection(_progetti);

  void setA1A5(String newValue) {
    _a1a5 = newValue;
    notifyListeners();
  }

  void setCategorie(String newValue) {
    _categorie = newValue;
    notifyListeners();
  }

  void setConti(String newValue) {
    _conti = newValue;
    notifyListeners();
  }

  void setProgetti(String newValue) {
    _progetti = newValue;
    notifyListeners();
  }
}