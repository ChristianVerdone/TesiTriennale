import 'dart:convert';

import 'package:flutter/services.dart';

import 'model/Conto.dart';
class Utils{
  static List<T> modelBuilder<M, T>(
      List<M> models, T Function(int index, M model) builder )=>
      models
      .asMap()
      .map<int, T>((index, model) => MapEntry(index, builder(index, model)))
      .values
      .toList();




}
const platform = MethodChannel('mychannel');

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

List<Conto> convertMapToObject(List<Map<String, dynamic>> csvData) => csvData
    .map((item) => Conto(
    codiceConto: item['Codice Conto'],
    descrizioneConto: item['Descrizione conto'],
    dataOperazione: item['Data operazione'],
    COD: item['COD'].toString(),
    descrizioneOperazione: item['Descrizione operazione'],
    numeroDocumento: item['Numero documento'].toString(),
    dataDocumento: item['Data documento'],
    numeroFattura: item['Numero Fattura'].toString(),
    importo: item['Importo'].toString(),
    saldo: item['Saldo'].toString(),
    contropartita: item['Contropartita'],

    costiDiretti: item['Costi Diretti'].toString() == "" ? false : item['Costi Diretti'],

    costiIndiretti: item['Costi Indiretti'].toString() == "" ? false : item['Costi Indiretti'],

    attivitaEconomiche: item['Attività economiche'].toString() == "" ? false : item['Attività economiche'],

    attivitaNonEconomiche: item['Attività non economiche'].toString() == "" ? false : item['Attività non economiche'],

    codiceProgetto: item['Codice progetto']))
    .toList();