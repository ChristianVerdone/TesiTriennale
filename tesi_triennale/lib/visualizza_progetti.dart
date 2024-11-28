import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:tesi_triennale/progetto.dart';
import 'package:tesi_triennale/utils.dart';
import 'app_state.dart';
import 'conto.dart';
import 'get_progetto.dart';
import 'insert_progetto.dart';
import 'package:pdf/widgets.dart' as pw;

class VisualizzaProg extends StatefulWidget {
  const VisualizzaProg({super.key});
  @override
  State<VisualizzaProg> createState() => _VisualizzaProgState();
}

class _VisualizzaProgState extends State<VisualizzaProg> {
  num totProgettiE = 0;
  num totProgettinE = 0;
  num totProgPerPercEco = 0;
  num totProgPerPercNonEco = 0;
  List<String> progetti = [];
  List<Map<String, dynamic>> csvData = [];
  List<Conto> conti = [];
  num n = 0;
  String refresh = '';
  List<DocumentReference> documentReferences = [];
  bool _isProcessing = false;
  bool _isValuating = false;

  @override
  void initState() {
    processProgetti(context);
    _isValuating = true;
    valuatetot();
    super.initState();
  }

  void reload(){
    setState(() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const VisualizzaProg(),),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Progetti'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                String refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => const InsertProgetto()));
                if(refresh == 'refresh'){
                  reload();
                }
              },
              child: const Icon(Icons.add)
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              onPressed: () {
                Printing.layoutPdf(onLayout: (format) => _generatePdfContent());
              },
              child: const Icon(Icons.print),
            ),
            IconButton(
              onPressed: (){
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              icon: const Icon(Icons.home)),
            const SizedBox(width: 16),
            IconButton(
              onPressed: _isProcessing ? null : _evaluateAllProjects,
              icon: const Icon(Icons.refresh),
            ),
          ]
      ),
      body:_isProcessing || _isValuating
          ? const Center(
        child: CircularProgressIndicator(),
      )
          :Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: progetti.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: GetProgetto(idProg: progetti[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _evaluateAllProjects() async {
    setState(() {
      _isProcessing = true;
    });

      final appState = Provider.of<AppState>(context, listen: false);
      QuerySnapshot snapshot = await appState.progetti.get();
      for (var doc in snapshot.docs) {
        if (doc.id != 'DefaultProject') {
          await evaluate(doc.id);
        }
      }
      setState(() {
        _isProcessing = false;
      });
  }

  Future getProgetti() async{
    print(totProgPerPercNonEco);
    print(totProgPerPercEco);
    double perc = 0;
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.progetti.get().then(
      (snapshot) => snapshot.docs.forEach(
        (progetto) {
          if(progetto.reference.id != 'DefaultProject') {
            if (!(progetti.contains(progetto.reference.id))) {
              progetti.add(progetto.reference.id);
            }
            if (progetto.reference.id != 'GIROCONTO') {
              if (progetto.get('isEconomico')) {
                if (progetto.get('Contributo Competenza').toString().contains(
                    '-')) {
                  perc = 0;
                }
                else {
                  perc = (num.parse(
                      progetto.get('Contributo Competenza').toString()) /
                      totProgPerPercEco) * 100;
                }
              }
              else {
                if (progetto.get('Contributo Competenza').toString().contains(
                    '-')) {
                  perc = 0;
                }
                else {
                  perc = (num.parse(
                      progetto.get('Contributo Competenza').toString()) /
                      totProgPerPercNonEco) * 100;
                }
              }
              final json = {
                'Percentuale': perc.toString(),
              };
              progetto.reference.update(json);
            }
            perc = 0;
          }
        }
      )
    );
  }

  double roundToTwoDecimalPlaces(double value) {
    return (value * 100).round() / 100;
  }

  Future<void> valuatetot() async {
    List<dynamic> contiRef = [];
    Map<String, dynamic>? data;
    double valoreProduzione = 0;
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.progetti.get().then(
      (snap) => snap.docs.forEach(
        (progetto) {
          if(progetto.reference.id != 'DefaultProject'){
            if(progetto.get('isEconomico')){
              if(progetto.get('Contributo Competenza').toString().contains('-') || progetto.id == 'GIROCONTO'){
                totProgettiE = totProgettiE + num.parse(progetto.get('Contributo Competenza').toString());
              }
              else{
                totProgPerPercEco = totProgPerPercEco + num.parse(progetto.get('Contributo Competenza').toString());
                totProgettiE = totProgettiE + num.parse(progetto.get('Contributo Competenza').toString());
              }
            }
            else {
              if (progetto.get('Contributo Competenza').toString().contains(
                  '-') || progetto.id == 'GIROCONTO') {
                totProgettinE = totProgettinE +
                    num.parse(progetto.get('Contributo Competenza').toString());
              }
              else {
                totProgPerPercNonEco = totProgPerPercNonEco + num.parse(progetto.get('Contributo Competenza').toString());
                totProgettinE = totProgettinE +
                    num.parse(progetto.get('Contributo Competenza').toString());
              }
            }
          }
        }
      )
    );

    await appState.categorie.doc('Valore della Produzione').get().then(
      (value) async {
        if(value.exists){
          var data = value.data() as Map<String, dynamic>?;
          contiRef = data!['Conti'];
          for (var conto in contiRef) {
            DocumentReference s = conto as DocumentReference;
            DocumentSnapshot documentSnapshot = await appState.conti.doc(s.id).get();
            if (documentSnapshot.exists) {
              data = documentSnapshot.data() as Map<String, dynamic>?;
            }
            valoreProduzione = valoreProduzione + data!['Saldo'].abs();
          }
        }
      }
    );
    var valNonEconomico = valoreProduzione - totProgettiE;
    // Calculate percentages
    double percValoreProduzioneNonE = valoreProduzione != 0 ? (valNonEconomico / valoreProduzione) * 100 : 0;
    double percTotProgettiE = valoreProduzione != 0 ? (totProgettiE / valoreProduzione) * 100 : 0;

    final json = {
      'ValoreProduzione': valoreProduzione,
      'ValoreProduzioneNonE': valNonEconomico,
      'ValoreProduzioneE': totProgettiE,
      'totProgettiE': totProgettiE,
      'totProgettinE': totProgettinE,
      'percValoreProduzioneNonE': percValoreProduzioneNonE,
      'percTotProgettiE': percTotProgettiE,
    };
    await appState.categorie.doc('Valore della Produzione').set(json,
        SetOptions(merge: true));

    await getProgetti();
    setState(() {
      _isValuating = false;
    });
  }

  Future getLinesProg(Progetto p) async {
    csvData = [];
    conti = [];
    final appState = Provider.of<AppState>(context, listen: false);
    for(var ref in p.references){
      await appState.firestore.doc(ref).get().then(
        (linea) {
          if(linea.reference.id != 'defaultLine'){
            var data = linea.data();
            Map<String, dynamic>? c = data;
            csvData.add(c!);
          }
        },
      );
    }
    conti = convertMapToObject2(csvData);
  }

  List<List<dynamic>> _makeListConti(Progetto project) {
    if (conti.isEmpty) {
      return [];
    }
    List<List<dynamic>> list = [];
    final columns = [
      'Codice Conto',
      'Descrizione conto',
      'Data operazione',
      'Descrizione operazione',
      'Data documento',
      'Numero documento',
      'Importo',
      'Codice Fiscale',
      'Partita IVA',
      'Contropartita',
      'Costi diretti',
      'Costi indiretti',
      'Attivita economiche',
      'Attivita non economiche',
      'Codice progetto',
      'Project Amounts'
    ];
    list.add(columns);
    int i = 0;
    for (var conto in conti) {
      if(i/34 >= 1){
        list.add(columns);
        list.add(conto.toListFPAmounts(project.nomeProgetto));
        i = 0;
      }
      else{
        list.add(conto.toListFPAmounts(project.nomeProgetto));
        i++;
      }
    }
    return list;
  }

  FutureOr<Uint8List> _generatePdfContent() async{
    final appState = Provider.of<AppState>(context, listen: false);
    CollectionReference progettiRef = appState.progetti;
    Progetto prog;
    List<List> tableData;
    // Load the image as a Uint8List
    final ByteData bytes = await rootBundle.load('assets/images/CeRICT_logo.png');
    final Uint8List imageData = bytes.buffer.asUint8List();
    final image = pw.MemoryImage(imageData);
    final fontRegular = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
    final fontBold = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));
    final pdf = pw.Document();
    const contentPerPage = 35;
    for(String p in progetti){
      final value = await progettiRef.doc(p).get();
      prog = Progetto.prog(nomeProgetto: p, anno: value.get('Anno'),
          valore: value.get('Valore'), costiDiretti: value.get('Costi Diretti'),
          costiIndiretti: value.get('Costi Indiretti'),
          isEconomico: value.get('isEconomico'), perc: value.get('Percentuale'),
          contributo: value.get('Contributo Competenza'),
          references: value.get('CostiDirettiValue'), isA1: (value.data() as
          Map<String, dynamic>).containsKey('isA1') ?
          value.get('isA1') : false, isA5: (value.data() as
          Map<String, dynamic>).containsKey('isA5') ?
          value.get('isA5') : false);
      await getLinesProg(prog);
      tableData = await _makeListConti(prog);
      var totalPageCount = 0;
      if (tableData.isNotEmpty) {
        totalPageCount = (tableData.length / contentPerPage).ceil();
      }
      pw.Page page = _buildSummaryPage(prog, image, fontRegular, fontBold);
      pdf.addPage(page);
      if(totalPageCount != 0){
        for (int pageIndex = 1; pageIndex < (totalPageCount + 1); pageIndex++) {
          final startIndex = (pageIndex - 1) * contentPerPage;
          final endIndex = pageIndex * contentPerPage;
          final currentPageData = tableData.sublist(startIndex, endIndex > tableData.length ? tableData.length : endIndex);

          final table = pw.TableHelper.fromTextArray(
            data: currentPageData,
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(5),
            headerDecoration: const pw.BoxDecoration(
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
              color: PdfColors.grey,
            ),
            cellStyle: pw.TextStyle(fontSize: 4,font: pw.Font.helvetica()),
            headerStyle: pw.TextStyle(fontSize: 4, font: pw.Font.helvetica()),
          );

          pw.Page p = pw.Page(
            orientation: pw.PageOrientation.landscape,
            margin: const pw.EdgeInsets.all(3),
            build: (pw.Context context) {
              return pw.Column(
                children: [
                  pw.Padding( // Aggiunto il widget Padding
                    padding: const pw.EdgeInsets.all(10), // Aggiunto un margine di 10
                    child: pw.Expanded( // Aggiunto il widget Expanded
                      child: pw.Center(
                        child: pw.Container(
                          child: table,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          pdf.addPage(p);
        }
      }
    }
    return pdf.save();
  }

  pw.Page _buildSummaryPage(Progetto prog, pw.MemoryImage image, pw.Font fontRegular, pw.Font fontBold) {
  return pw.Page(
    margin: const pw.EdgeInsets.all(3),
    build: (pw.Context context) {
      return pw.Center(
        child: pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(image, width: 100, height: 100),
                pw.Text(
                  'Riepilogo Progetto: ${prog.nomeProgetto}',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, font: fontBold),
                ),
                pw.SizedBox(width: 100),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'L\'anno di riferimento: ${prog.anno}, il progetto nella sua interezza assume un valore di: ${prog.valore} \u20AC.',
              style: pw.TextStyle(fontSize: 12, font: fontRegular),
            ),
            pw.Text(
              prog.isEconomico ? 'Il Progetto \u00E8 di natura economica' : 'Il Progetto \u00E8 di natura non economica',
              style: pw.TextStyle(fontSize: 12, font: fontRegular),
            ),
            pw.Text(
              'Il contributo di competenza per l\'anno di riferimento \u00E8 di: ${prog.contributo} \u20AC.',
              style: pw.TextStyle(fontSize: 12, font: fontRegular),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'I Costi Diretti associati al progetto divisi per categoria sono:',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(fontSize: 12, font: fontRegular),
            ),
            for (var entry in prog.costiDiretti.entries)
              pw.Container(
                child: pw.Text(
                  '${entry.key}:     ${entry.value} \u20AC',
                  style: pw.TextStyle(fontSize: 12, font: fontRegular),
                ),
                alignment: pw.Alignment.centerLeft,
              ),
            pw.Text(
              'Totale:${getSum(prog.costiDiretti.values)} \u20AC',
              style: pw.TextStyle(fontSize: 12, font: fontRegular),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'I Costi Indiretti associati al progetto divisi per categoria sono:',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(fontSize: 12, font: fontRegular),
            ),
            for (var entry in prog.costiIndiretti.entries)
              pw.Container(
                child: pw.Text(
                  '${entry.key}:     ${entry.value} \u20AC',
                  style: pw.TextStyle(fontSize: 12, font: fontRegular),
                ),
                alignment: pw.Alignment.centerLeft,
              ),
            pw.Text(
              'Totale:${getSum(prog.costiIndiretti.values)} \u20AC',
              style: pw.TextStyle(fontSize: 12, font: fontRegular),
            ),
          ],
        ),
      );
    },
  );
}

  num getSum(Iterable<dynamic> iterable) {
    n = 0;
    for (var element in iterable) {
      n = n + num.parse(element) ;
    }
    return n;
  }

  Future<Progetto> getProgetto(String nomeProgetto) async {
    Progetto p = Progetto.prog(nomeProgetto: '', anno: 0, valore: 0,
        costiDiretti: {}, costiIndiretti: {}, isEconomico: false, perc: 0,
        contributo: 0, references: [], isA1: false, isA5: false);
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.progetti.doc(nomeProgetto).get().then(
      (value) {
        p = Progetto.prog(nomeProgetto: nomeProgetto, anno: value.get('Anno'),
          valore: value.get('Valore'), costiDiretti: value.get('Costi Diretti'),
          costiIndiretti: value.get('Costi Indiretti'),
          isEconomico: value.get('isEconomico'), perc: value.get('Percentuale'),
          contributo: value.get('Contributo Competenza'),
          references: value.get('CostiDirettiValue'), isA1: value.get('isA1'),
          isA5: value.get('isA5'));
      }
    );
    return p;
  }

  evaluate(String nomeProgetto) async {
    documentReferences = [];
    Progetto p = await getProgetto(nomeProgetto);
    num s;
    final appState = Provider.of<AppState>(context, listen: false);
    for (var categoria in p.costiDiretti.keys) {
      s = 0;
      await appState.categorie.doc(categoria).get().then(
              (cat) async {
            if(cat.reference.id == 'Personale'){
              for (var element in (cat.get('Conti') as List<dynamic>)) {
                DocumentReference d = element as DocumentReference;
                await appState.conti.doc(d.id).collection('lineeConto').get().
                  then(
                        (value) => value.docs.forEach((linea) {
                      if (linea.reference.id != 'defaultLine') {
                        var projectAmounts = linea.data()['Project Amounts'];
                        LinkedHashMap<String, double> progetti = projectAmounts != null
                            ? LinkedHashMap<String, double>.from(projectAmounts.map((key, value) => MapEntry(key, value.toDouble())))
                            : LinkedHashMap<String, double>();                        if (progetti.containsKey(nomeProgetto) && linea.get('Costi Diretti') == true) {
                          s = s + num.parse(progetti[nomeProgetto].toString());
                          // Aggiungi il DocumentReference all'array
                          documentReferences.add(linea.reference);
                        }
                      }
                    })
                );
              }
            }
            else {
              for (var element in (cat.get('Conti') as List<dynamic>)) {
                DocumentReference d = element as DocumentReference;
                await appState.conti.doc(d.id).collection('lineeConto').get().
                  then(
                        (value) => value.docs.forEach( (linea) {
                      if (linea.reference.id != 'defaultLine') {
                        var c = linea.data()['Codice progetto']
                            .toString();
                        if (c == nomeProgetto &&
                            linea.get('Costi Diretti') == true) {
                          s = s + num.parse(linea.get('Importo')
                              .toString());
                          // Aggiungi il DocumentReference all'array
                          documentReferences.add(linea.reference);
                        }
                      }
                    })
                );
              }
            }
          }
      );
      p.costiDiretti.update(categoria, (value) => s.toStringAsFixed(2));
    }
    num totCostiIndAE = 0;
    num totCostiIndAnE = 0;
    DocumentSnapshot riepilogoCatDoc = await appState.categorie.doc(''
        'riepilogoCat').get();
    totCostiIndAE = num.parse(riepilogoCatDoc.get(''
        'totCostiIndirettiAttEco').toString());
    totCostiIndAnE = num.parse(riepilogoCatDoc.get(''
        'totCostiIndirettiAttNonEco').toString());

    for (var categoria in p.costiIndiretti.keys) {
      s = 0;
      await appState.categorie.doc(categoria).get().then(
              (cat) {
            if(p.isEconomico){
              s = (num.parse(p.perc.toString()) / 100 * totCostiIndAE) *
                  num.parse(cat.get('Percentuale CI A E').toString()) / 100;
            }
            else {
              s = (num.parse(p.perc.toString()) / 100 * totCostiIndAnE) *
                  num.parse(cat.get('Percentuale CI A nE').toString()) / 100;
            }
          }
      );
      p.costiIndiretti.update(categoria, (value) => s.toStringAsFixed(2));
    }
    final json = {
      'Costi Diretti' : p.costiDiretti, 'Costi Indiretti' : p.costiIndiretti,
      'CostiDirettiValue': documentReferences.map((docRef) =>
      docRef.path).toList(),
    };
    await appState.progetti.doc(nomeProgetto).update(json);
  }
}