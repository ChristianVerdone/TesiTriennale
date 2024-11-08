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
  List<Conto> conti = convertMapToObject2(csvData);
  return conti;
}

Future<List<DocumentReference>> getContiPersonale() async {
  List<DocumentReference> contiPersonale = [];
  try {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('categorie').doc('Personale').get();
    if (documentSnapshot.exists) {
      contiPersonale = List<DocumentReference>.from(documentSnapshot.get('Conti'));
    } else {
      print('Document does not exist');
    }
  } catch (e) {
    print('Error getting document: $e');
  }
  return contiPersonale;
}

void calcolaSommaImporti(String idConto) async {
  DocumentReference contoRef = FirebaseFirestore.instance.collection('conti').doc(idConto);
  List<Conto> conti = await getLines(idConto);
  List<DocumentReference> contiPersonale = await getContiPersonale();
  double somma = 0.0;
  double totIndiretti = 0.0;
  double totDnE = 0.0;
  double totDE = 0.0;
  double importo = 0.0;
  double sum = 0.0;
  for (var conto in conti) {
    if(conto.importo is String){
      importo = double.parse(conto.importo);
      somma += importo;
    }
    else{
      importo = conto.importo;
      somma += importo;
    }
    if(conto.costiIndiretti){
      if(!conto.attivitaNonEconomiche && !conto.attivitaEconomiche){
        totIndiretti = totIndiretti + importo;
      }
    }
    if(conto.costiDiretti){
      if(contiPersonale.contains(contoRef)){
        if(conto.attivitaNonEconomiche) {
          LinkedHashMap<String, double>? projectAmounts = conto.projectAmounts;
          sum = 0.0;
          if (projectAmounts != null) {
            sum += projectAmounts.values.reduce((a, b) => a + b);
            if(sum == importo){
              totDnE = totDnE + importo;
            }
            else{
              var diff = importo - sum;
              totIndiretti = totIndiretti + diff;
              totDnE = totDnE + sum;
            }
          }
        }
        if(conto.attivitaEconomiche){
          LinkedHashMap<String, double>? projectAmounts = conto.projectAmounts;
          sum = 0.0;
          if (projectAmounts != null) {
            sum += projectAmounts.values.reduce((a, b) => a + b);
            if(sum == importo){
              totDE = totDE + importo;
            }
            else{
              var diff = importo - sum;
              totIndiretti = totIndiretti + diff;
              totDE = totDE + sum;
            }
          }
        }
      }
      else{
        if(conto.attivitaNonEconomiche) {
          totDnE = totDnE + importo;
        }
        if(conto.attivitaEconomiche){
          totDE = totDE + importo;
        }
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

bool valuate = true;

Future<void> processProgetti() async {
  if(valuate) {
    final collectionRef = FirebaseFirestore.instance.collection('A1-A5');
    final documents = ['A1', 'A5'];

    for (var docId in documents) {
      DocumentSnapshot documentSnapshot = await collectionRef.doc(docId).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        List<String> progetti = List<String>.from(data['PROGETTI'] ?? []);

        double totalEconomic = 0.0;
        double totalNonEconomic = 0.0;

        for (var progetto in progetti) {
          DocumentSnapshot progettoSnapshot = await FirebaseFirestore.instance
              .collection('progetti').doc(progetto).get();
          if (progettoSnapshot.exists) {
            Map<String, dynamic> progettoData = progettoSnapshot.data() as Map<String, dynamic>;
            double contributo = double.parse(progettoData['Contributo Competenza']) ?? 0.0;
            bool isEconomic = progettoData['isEconomico'] ?? false;

            if (isEconomic) {
              totalEconomic += contributo;
            } else {
              totalNonEconomic += contributo;
            }
          }
        }
        double total = totalEconomic + totalNonEconomic;

        await collectionRef.doc(docId).update({
          'Totale': total,
          'totalEconomic': totalEconomic,
          'totalNonEconomic': totalNonEconomic,
        });
      } else {
        print('Document $docId does not exist');
      }
    }
  }
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
  double totCostiAttEco = 0.0;
  double totCostiAttNonEco = 0.0;

  // Itera su ogni categoria
  for (var categoriaDoc in categorieSnapshot.docs) {
    if (categoriaDoc.id != 'riepilogoCat' && categoriaDoc.id != 'Valore della Produzione') {
      var data = categoriaDoc.data() as Map<String, dynamic>;
      if(categoriaDoc.id.toString() == 'Oneri finanziari'){
        saldoOneriFinanziari = data['Totale Costi Diretti A E'] ?? 0.0;
        saldoOneriFinanziari += data['Totale Costi Diretti A nE'] ?? 0.0;
        saldoOneriFinanziari += data['Totale Costi Indiretti A E'] ?? 0.0;
        saldoOneriFinanziari += data['Totale Costi Indiretti A nE'] ?? 0.0;
      }
      else {
        // Somma i valori parziali esistenti
        totCostiDirettiAttEco += data['Totale Costi Diretti A E'] ?? 0.0;
        totCostiDirettiAttNonEco += data['Totale Costi Diretti A nE'] ?? 0.0;
        /*totCostiIndirettiAttEco += data['Totale Costi Indiretti A E'] ?? 0.0;
      totCostiIndirettiAttNonEco += data['Totale Costi Indiretti A nE'] ?? 0.0;
      */
      }
    }
  }

  DocumentSnapshot value = await FirebaseFirestore.instance.collection('categorie').doc('Valore della Produzione').get();

  // Recupera tutti i conti
  QuerySnapshot contiSnapshot = await FirebaseFirestore.instance.collection('conti').get();

  // Somma i saldi di ogni categoria
  for (var categoriaDoc in categorieSnapshot.docs) {
    if (categoriaDoc.id != 'Oneri finanziari' && categoriaDoc.id != 'riepilogoCat' && categoriaDoc.id != 'Valore della Produzione') {
      var data = categoriaDoc.data() as Map<String, dynamic>;
      costiDiProduzione += data['Saldo'] ?? 0.0;
      if (kDebugMode) {
        print('Categoria ID: ${categoriaDoc.id}, Saldo: ${data['Saldo']}');
      }
    }
  }
  //costiDiProduzione = costiDiProduzione - saldoOneriFinanziari;
  totCostiAttEco = costiDiProduzione * value.get('percTotProgettiE') / 100;
  totCostiAttNonEco = costiDiProduzione * value.get('percValoreProduzioneNonE') / 100;
  print('Costi att eco: $totCostiAttEco');
  print('Costi att non eco: $totCostiAttNonEco');
  totCostiIndirettiAttEco = totCostiAttEco - totCostiDirettiAttEco;
  totCostiIndirettiAttNonEco = totCostiAttNonEco - totCostiDirettiAttNonEco;
  print('Costi indiretti att eco: $totCostiIndirettiAttEco');
  print('Costi indiretti att non eco: $totCostiIndirettiAttNonEco');
  totIndiretti = totCostiIndirettiAttEco + totCostiIndirettiAttNonEco;

  // Calcola le percentuali
  double percIndirettiAttEco = totIndiretti != 0 ? (totCostiIndirettiAttEco / totIndiretti) * 100 : 0;
  double percIndirettiAttNonEco = totIndiretti != 0 ? (totCostiIndirettiAttNonEco / totIndiretti) * 100 : 0;

  // Salva i risultati nel documento riepilogoCat nella collezione categorie
  await FirebaseFirestore.instance.collection('categorie').doc('riepilogoCat').set({
    'totCostiAttEco': totCostiAttEco,
    'totCostiAttNonEco': totCostiAttNonEco,
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