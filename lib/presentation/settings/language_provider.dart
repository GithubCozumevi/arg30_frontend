import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _lang = "tr"; // varsayılan dil

  String get lang => _lang;

  void setLang(String newLang) {
    _lang = newLang;
    notifyListeners();
  }
}
