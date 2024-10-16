import 'dart:collection';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
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

Future<List<Conto>> getLines(String idConto) async {
  List<String> lines = [];
  List<Map<String, dynamic>> csvData = [];
  await FirebaseFirestore.instance.collection('conti/$idConto/lineeConto').get().then(
          (snapshot) => snapshot.docs.forEach((linea) {
        if(linea.reference.id != 'defaultLine'){
          Map<String, dynamic> c = linea.data();
          lines.add(linea.id);
          csvData.add(c);
        }
      })
  );
  List<Conto> conti = convertMapToObject(csvData);
  return conti;
}

void calcolaSommaImporti(String idConto) async {
  List<Conto> conti = await getLines(idConto);
  double somma = 0.0;
  double totIndiretti = 0.0;
  double totDnE = 0.0;
  double totDE = 0.0;
  for (var conto in conti) {
    somma += double.parse(conto.importo.toString());
    if(conto.costiIndiretti){
      if(!conto.attivitaNonEconomiche && !conto.attivitaEconomiche){
        totIndiretti = totIndiretti + num.parse(conto.importo);
      }
    }
    if(conto.costiDiretti){
      if(conto.attivitaNonEconomiche) {
        totDnE = totDnE + num.parse(conto.importo);
      }
      if(conto.attivitaEconomiche){
        totDE = totDE + num.parse(conto.importo);
      }
    }
  }
  if (kDebugMode) {
    print('La somma degli importi è: \$${somma.toStringAsFixed(2)}');
  }

  // Update the Saldo attribute in the conti/idConto document on Firebase
  await FirebaseFirestore.instance.collection('conti').doc(idConto).update({
    'Saldo': somma,
    'TotaleCostiIndiretti': totIndiretti,
    'TotaleCostiDirettiNonEconomici': totDnE,
    'TotaleCostiDirettiEconomici': totDE
  });
}

Future<void> calcolaEInserisciRiepilogoCat() async {
  // Recupera tutte le categorie
  QuerySnapshot categorieSnapshot = await FirebaseFirestore.instance.collection('categorie').get();

  // Inizializza le variabili per i calcoli
  double totCostiDirettiAttEco = 0.0;
  double totCostiDirettiAttNonEco = 0.0;
  double totCostiIndirettiAttEco = 0.0;
  double totCostiIndirettiAttNonEco = 0.0;
  double totIndiretti = 0.0;
  double costiDiProduzione = 0.0;
  double saldoOneriFinanziari = 0.0;

  // Itera su ogni categoria
  for (var categoriaDoc in categorieSnapshot.docs) {
    if (categoriaDoc.id != 'riepilogoCat') {
      print('Categoria: ${categoriaDoc.id}');
      var data = categoriaDoc.data() as Map<String, dynamic>;
      print('Data: $data');
      if(categoriaDoc.id.toString() == 'Oneri finanziari'){
        saldoOneriFinanziari = data['Totale Costi Diretti A E'] ?? 0.0;
        saldoOneriFinanziari += data['Totale Costi Diretti A nE'] ?? 0.0;
        saldoOneriFinanziari += data['Totale Costi Indiretti A E'] ?? 0.0;
        saldoOneriFinanziari += data['Totale Costi Indiretti A nE'] ?? 0.0;
      }
      // Somma i valori parziali esistenti
      totCostiDirettiAttEco += data['Totale Costi Diretti A E'] ?? 0.0;
      totCostiDirettiAttNonEco += data['Totale Costi Diretti A nE'] ?? 0.0;
      totCostiIndirettiAttEco += data['Totale Costi Indiretti A E'] ?? 0.0;
      totCostiIndirettiAttNonEco += data['Totale Costi Indiretti A nE'] ?? 0.0;
    }
  }

  // Recupera tutti i conti
  QuerySnapshot contiSnapshot = await FirebaseFirestore.instance.collection('conti').get();

  // Somma i saldi di ogni conto
  for (var contoDoc in contiSnapshot.docs) {
    var data = contoDoc.data() as Map<String, dynamic>;
    costiDiProduzione += data['Saldo'] ?? 0.0;
  }

  costiDiProduzione = costiDiProduzione - saldoOneriFinanziari;
  
  totIndiretti = totCostiIndirettiAttEco + totCostiIndirettiAttNonEco;
  // Calcola le percentuali
  double percIndirettiAttEco = totIndiretti != 0 ? (totCostiIndirettiAttEco / totIndiretti) * 100 : 0;
  double percIndirettiAttNonEco = totIndiretti != 0 ? (totCostiIndirettiAttNonEco / totIndiretti) * 100 : 0;

  // Salva i risultati nel documento riepilogoCat nella collezione categorie
  await FirebaseFirestore.instance.collection('categorie').doc('riepilogoCat').set({
    'percIndirettiAttEco': percIndirettiAttEco,
    'percIndirettiAttNonEco': percIndirettiAttNonEco,
    'totCostiDirettiAttEco': totCostiDirettiAttEco,
    'totCostiDirettiAttNonEco': totCostiDirettiAttNonEco,
    'totCostiIndirettiAttEco': totCostiIndirettiAttEco,
    'totCostiIndirettiAttNonEco': totCostiIndirettiAttNonEco,
    'Costi di produzione': costiDiProduzione,
  }, SetOptions(merge: true));
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