import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';

class TranslationProvider with ChangeNotifier {
  Map<String, String> _localizedStrings = {};
  Locale _locale = Locale('en');

  Locale get locale => _locale;

  Future<void> load(Locale locale) async {
    _locale = locale;
    String xmlString = await rootBundle
        .loadString('assets/strings_${locale.languageCode}.xml');
    final document = XmlDocument.parse(xmlString);
    final resources = document.findAllElements('string');
    _localizedStrings = {
      for (var element in resources)
        element.getAttribute('name')!: element.text,
    };
    notifyListeners();
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}
