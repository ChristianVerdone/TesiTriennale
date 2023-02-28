import 'dart:convert';

import 'package:flutter/services.dart';
class Utils{
  static List<T> modelBuilder<M, T>(
      List<M> models, T Function(int index, M model) builder )=>
      models
      .asMap()
      .map<int, T>((index, model) => MapEntry(index, builder(index, model)))
      .values
      .toList();




}
const platform = const MethodChannel('mychannel');

Future<int?> myDartFunction(int arg) async {
  try {
    final result = await platform.invokeMethod('myPythonFunction', {'arg': arg});
    final parsedResult = json.decode(result);
    return parsedResult['result'];
  } on PlatformException catch (e) {
    print("Error: ${e.message}");
  }
  return null;
}