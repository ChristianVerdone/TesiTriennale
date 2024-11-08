import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:tesi_triennale/progetto.dart';
import 'package:tesi_triennale/utils.dart';
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
    processProgetti();
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
                // Printing.layoutPdf(onLayout: (format) => _generatePdfContent());
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

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('progetti').get();
      for (var doc in snapshot.docs) {
        if (doc.id != 'DefaultProject') {
          await evaluate(doc.id);
        }
      }
    } catch (e) {
      // Handle errors if necessary
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future getProgetti() async{
    num perc = 0;
    await FirebaseFirestore.instance.collection('progetti').get().then(
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
                'Percentuale': perc.toStringAsFixed(2),
              };
              progetto.reference.update(json);
            }
            perc = 0;
          }
        }
      )
    );
  }

  Future<void> valuatetot() async {
    List<dynamic> contiRef = [];
    Map<String, dynamic>? data;
    double valoreProduzione = 0;
    await FirebaseFirestore.instance.collection('progetti').get().then(
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

    await FirebaseFirestore.instance.collection('categorie').doc('Valore della Produzione').get().then(
      (value) async {
        if(value.exists){
          contiRef = value.data()!['Conti'];
          for (var conto in contiRef) {
            DocumentReference s = conto as DocumentReference;
            DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('conti').doc(s.id).get();
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
    await FirebaseFirestore.instance.collection('categorie').doc('Valore della Produzione').set(json,
        SetOptions(merge: true));

    await getProgetti();
    setState(() {
      _isValuating = false;
    });
  }

  Future getLinesProg(Progetto p) async {
    conti = [];
    for(var ref in p.references){
      await FirebaseFirestore.instance.doc(ref).get().then(
        (linea) {
          if(linea.reference.id != 'defaultLine'){
            var data = linea.data();
            Map<String, dynamic>? c = data;
            csvData.add(c!);
          }
        },
      );
    }
    conti = convertMapToObject(csvData);
  }

  List<List<dynamic>> _makeListConti() {
    List<List<dynamic>> list = [];
    final columns = [
      'Codice Conto',
      'Descrizione conto',
      'Data operazione',
      'Descrizione operazione',
      'Data documento',
      'Numero documento',
      'Importo',
      'Saldo',
      'Contropartita',
      'Costi diretti',
      'Costi indiretti',
      'Attivita economiche',
      'Attivita non economiche',
      'Codice progetto'
    ];
    list.add(columns);
    int i = 0;
    for (var conto in conti) {
      if(i/14 >= 1){
        list.add(conto.toListF());
        list.add(columns);
      }
      else{
        list.add(conto.toListF());
      }
    }
    return list;
  }

  FutureOr<Uint8List> _generatePdfContent() async{
    CollectionReference progettiRef = FirebaseFirestore.instance.collection('progetti');
    Progetto prog;
    List<List> tableData;
    final pdf = pw.Document();
    const contentPerPage = 20;
    for(String p in progetti){
      await progettiRef.doc(p).get().then((value) {
        prog = Progetto.prog(nomeProgetto: p, anno: value.get('Anno'), valore: value.get('Valore'), costiDiretti: value.get('Costi Diretti'),
          costiIndiretti: value.get('Costi Indiretti'), isEconomico: value.get('isEconomico'), perc: value.get('Percentuale'),
          contributo: value.get('Contributo Competenza'), references: value.get('CostiDirettiValue'));
        getLinesProg(prog);
        tableData = _makeListConti();
        final totalPageCount = (tableData.length / contentPerPage).ceil();
        pdf.addPage(pw.Page(
          margin: const pw.EdgeInsets.all(3),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                children: [
                  pw.Text('${prog.nomeProgetto}'),
                  pw.Text('Anno: ${prog.anno} | Valore: ${prog.valore} | isEconomico: ${prog.isEconomico.toString()} | '
                    'Contributo di competenza: ${prog.contributo}',
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text('Costi Diretti:', textAlign: pw.TextAlign.left),
                  pw.ListView.builder(
                    itemCount: prog.costiDiretti.length,
                    itemBuilder: (context, index){
                      return pw.Container(
                        child: pw.Text('${prog.costiDiretti.keys.elementAt(index)}: ${prog.costiDiretti.values.elementAt(index)}'),
                      );
                    }
                  ),
                  pw.Text('Totale:${n = getSum(prog.costiDiretti.values)}'),
                  pw.SizedBox(height: 10),
                  pw.Text('Costi Indiretti:', textAlign: pw.TextAlign.left),
                  pw.ListView.builder(
                    itemCount: prog.costiIndiretti.length,
                    itemBuilder: (context, index){
                      return pw.Container(
                        child: pw.Text('${prog.costiIndiretti.keys.elementAt(index)}: ${prog.costiIndiretti.values.elementAt(index)}'),
                      );
                    }
                  ),
                  pw.Text('Totale:${n = getSum(prog.costiIndiretti.values)}'),
                ],
              ));
          },
        ));
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
          pdf.addPage(p, index: pageIndex,);
        }
      });
    }
    return pdf.save();
  }

  num getSum(Iterable<dynamic> iterable) {
    n = 0;
    for (var element in iterable) {
      n = n + num.parse(element) ;
    }
    return n;
  }

  Future<Progetto> getProgetto(String nomeProgetto) async {
    Progetto p = Progetto.prog(nomeProgetto: '', anno: 0, valore: 0, costiDiretti: {}, costiIndiretti: {}, isEconomico: false, perc: 0, contributo: 0, references: []);
    await FirebaseFirestore.instance.collection('progetti').doc(nomeProgetto).get().then(
      (value) {
        p = Progetto.prog(nomeProgetto: nomeProgetto, anno: value.get('Anno'), valore: value.get('Valore'), costiDiretti: value.get('Costi Diretti'),
          costiIndiretti: value.get('Costi Indiretti'), isEconomico: value.get('isEconomico'), perc: value.get('Percentuale'),
          contributo: value.get('Contributo Competenza'), references: value.get('CostiDirettiValue'));
      }
    );
    return p;
  }

  evaluate(String nomeProgetto) async {
    documentReferences = [];
    Progetto p = await getProgetto(nomeProgetto);
    num s;
    for (var categoria in p.costiDiretti.keys) {
      s = 0;
      await FirebaseFirestore.instance.collection('categorie').doc(categoria).get().then(
              (cat) async {
            if(cat.reference.id == 'Personale'){
              for (var element in (cat.get('Conti') as List<dynamic>)) {
                DocumentReference d = element as DocumentReference;
                await FirebaseFirestore.instance.collection('conti/${d.id}/lineeConto').get().then(
                        (value) => value.docs.forEach((linea) {
                      if (linea.reference.id != 'defaultLine') {
                        LinkedHashMap<String, double> progetti = LinkedHashMap<String, double>.from(linea.data()['Project Amounts'].map((key, value) => MapEntry(key, value.toDouble())));
                        if (progetti.containsKey(nomeProgetto) && linea.get('Costi Diretti') == true) {
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
                await FirebaseFirestore.instance.collection('conti/${d.id}/lineeConto').get().then(
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
    DocumentSnapshot riepilogoCatDoc = await FirebaseFirestore.instance.collection('categorie').doc('riepilogoCat').get();
    totCostiIndAE = num.parse(riepilogoCatDoc.get('totCostiIndirettiAttEco').toString());
    totCostiIndAnE = num.parse(riepilogoCatDoc.get('totCostiIndirettiAttNonEco').toString());

    for (var categoria in p.costiIndiretti.keys) {
      s = 0;
      await FirebaseFirestore.instance.collection('categorie').doc(categoria).get().then(
              (cat) {
            if(p.isEconomico){
              s = (num.parse(p.perc.toString()) / 100 * totCostiIndAE) * num.parse(cat.get('Percentuale CI A E').toString()) / 100;
            }
            else {
              s = (num.parse(p.perc.toString()) / 100 * totCostiIndAnE) * num.parse(cat.get('Percentuale CI A nE').toString()) / 100;
            }
          }
      );
      p.costiIndiretti.update(categoria, (value) => s.toStringAsFixed(2));
    }
    final json = {
      'Costi Diretti' : p.costiDiretti,
      'Costi Indiretti' : p.costiIndiretti,
      'CostiDirettiValue': documentReferences.map((docRef) => docRef.path).toList(),
    };
    await FirebaseFirestore.instance.collection('progetti').doc(nomeProgetto).update(json);
  }
}