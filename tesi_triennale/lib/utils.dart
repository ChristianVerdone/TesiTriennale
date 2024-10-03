import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'conto.dart';

class Utils{
  static List<T> modelBuilder<M, T>(List<M> models, T Function(int index, M model) builder )=>
    models.asMap().map<int, T>((index, model) => MapEntry(index, builder(index, model))).values.toList();
}

const platform = MethodChannel('mychannel');

Future<int?> myDartFunction(int arg) async {
  try {
    final result = await platform.invokeMethod('myPythonFunction', {'arg': arg});
    final parsedResult = json.decode(result);
    return parsedResult['result'];
  } on PlatformException catch (e) {
    if (kDebugMode) {
      print("Error: ${e.message}");
    }
  }
  return null;
}

List<Conto> filterConti(List<Conto> conti, String query) {
  if (query.isEmpty) {
    return conti;
  }
  final lowerCaseQuery = query.toLowerCase();
  return conti.where((conto) {
    return conto.codiceConto.toLowerCase().contains(lowerCaseQuery) ||
        conto.descrizioneConto.toLowerCase().contains(lowerCaseQuery) ||
        conto.dataOperazione.toLowerCase().contains(lowerCaseQuery) ||
        conto.descrizioneOperazione.toLowerCase().contains(lowerCaseQuery) ||
        conto.numeroDocumento.toLowerCase().contains(lowerCaseQuery) ||
        conto.dataDocumento.toLowerCase().contains(lowerCaseQuery) ||
        conto.importo.toLowerCase().contains(lowerCaseQuery) ||
        conto.saldo.toLowerCase().contains(lowerCaseQuery) ||
        conto.contropartita.toLowerCase().contains(lowerCaseQuery) ||
        conto.costiDiretti.toString().toLowerCase().contains(lowerCaseQuery) ||
        conto.costiIndiretti.toString().toLowerCase().contains(lowerCaseQuery) ||
        conto.attivitaEconomiche.toString().toLowerCase().contains(lowerCaseQuery) ||
        conto.attivitaNonEconomiche.toString().toLowerCase().contains(lowerCaseQuery) ||
        conto.codiceProgetto.toLowerCase().contains(lowerCaseQuery);
  }).toList();
}

List<Conto> convertMapToObject(List<Map<String, dynamic>> csvData) => csvData
    .map((item) => Conto(
    codiceConto: item['Codice Conto'],
    descrizioneConto: item['Descrizione conto'],
    dataOperazione: item['Data operazione'],
    descrizioneOperazione: item['Descrizione operazione'],
    numeroDocumento: item['Numero documento'].toString(),
    dataDocumento: item['Data documento'],
    importo: item['Importo'].toString(),
    saldo: item['Saldo'].toString(),
    contropartita: item['Contropartita'],
    costiDiretti: item['Costi Diretti'].toString() == "" ? false : item['Costi Diretti'],
    costiIndiretti: item['Costi Indiretti'].toString() == "" ? false : item['Costi Indiretti'],
    attivitaEconomiche: item['Attività economiche'].toString() == "" ? false : item['Attività economiche'],
    attivitaNonEconomiche: item['Attività non economiche'].toString() == "" ? false : item['Attività non economiche'],
    codiceProgetto: item['Codice progetto'])).toList();

List<Conto> convertMapToObject2(List<Map<String, dynamic>> csvData) => csvData
    .map((item) {
      var projectAmounts = item['Project Amounts'];
      if (projectAmounts == null) {
        projectAmounts = LinkedHashMap<String, double>();
      } else if (projectAmounts is LinkedHashMap) {
        projectAmounts = LinkedHashMap<String, double>.from(projectAmounts.map((key, value) => MapEntry(key, value.toDouble())));
      }
      return Conto(
        codiceConto: item['Codice Conto'],
        descrizioneConto: item['Descrizione conto'],
        dataOperazione: item['Data operazione'],
        descrizioneOperazione: item['Descrizione operazione'],
        numeroDocumento: item['Numero documento'].toString(),
        dataDocumento: item['Data documento'],
        importo: item['Importo'].toString(),
        saldo: item['Saldo'].toString(),
        contropartita: item['Contropartita'],
        costiDiretti: item['Costi Diretti'].toString() == "" ? false : item['Costi Diretti'],
        costiIndiretti: item['Costi Indiretti'].toString() == "" ? false : item['Costi Indiretti'],
        attivitaEconomiche: item['Attività economiche'].toString() == "" ? false : item['Attività economiche'],
        attivitaNonEconomiche: item['Attività non economiche'].toString() == "" ? false : item['Attività non economiche'],
        projectAmounts: projectAmounts,
        codiceProgetto: item['Codice progetto']
      );
    }).toList();