import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:tesi_triennale/utils.dart';
import 'package:tesi_triennale/visualizza_progetti.dart';
import 'conto.dart';
import 'modify_progetto.dart';
import 'progetto.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class VisualizzaProgetto extends StatefulWidget{
  const VisualizzaProgetto({super.key, required this.p});
  final Progetto p;

  @override
  State<VisualizzaProgetto> createState() => _VisualizzaProgettoState();
}

class _VisualizzaProgettoState extends State<VisualizzaProgetto> {
  List<String> categories= [];
  num n = 0;
  List<Map<String, dynamic>> csvData = [];
  List<Conto> conti = [];
  bool isLoading = true;
  List<DocumentReference> documentReferences = [];

  @override
  void initState() {
    super.initState();
    evaluateWithProgressDialog(widget.p.nomeProgetto).then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        actions: <Widget>[
          const SizedBox(width: 16),
          IconButton(
            onPressed: () async {
              await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Conferma Rimozione'),
                    content: const Text('Sei sicuro di voler rimuovere questo Progetto?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Annulla'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: const Text('Conferma'),
                        onPressed: () async {
                          // Add your removal logic here
                          await deleteProgetto();
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                },
              );
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VisualizzaProg()));
            },
            icon: const Icon(Icons.delete, color: Colors.red)),
          ElevatedButton(
            child: const Text('Modifica'),
            onPressed: () async {
              var refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => ModifyProgetto(progetto: widget.p)));
            },
          ),
          IconButton(
            onPressed: () {
              Printing.layoutPdf(onLayout: (format) => _generatePdfContent());
            },
            icon: const Icon(Icons.print),
          ),
          IconButton(
            onPressed: (){
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
            icon: const Icon(Icons.home)),
          const SizedBox(width: 16),
          /*
          ElevatedButton(
            onPressed: () async {
              await evaluateWithProgressDialog(widget.p.nomeProgetto);
              Navigator.of(context).pop(true);
            },
            child: const Text('Calcola costi')
          )
          */
        ],
        centerTitle: true,
        title: Text('Visualizzazione Progetto: ${widget.p.nomeProgetto}',
            style: const TextStyle(color: Colors.black, fontSize: 20.0)
        ),
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Center(
          child: Column(
            children: [
              Text('| Anno: ${widget.p.anno} | Valore: ${widget.p.valore} | isEconomico: ${widget.p.isEconomico.toString()} | '
              'Contributo di competenza: ${widget.p.contributo} |',
              ),
              const SizedBox(height: 20),
              const Text('Costi Diretti:', textAlign: TextAlign.left),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.p.costiDiretti.length,
                  itemExtent: 40,
                  itemBuilder: (context, index){
                    return ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text('${widget.p.costiDiretti.keys.elementAt(index)}: ${widget.p.costiDiretti.values.elementAt(index)}'),
                    );
                  }
                ),
              ),
              Text('Totale:${n = getSum(widget.p.costiDiretti.values)}'),
              const SizedBox(height: 20),
              const Text('Costi Indiretti:', textAlign: TextAlign.left),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.p.costiIndiretti.length,
                  itemExtent: 40,
                  itemBuilder: (context, index){
                    return ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text('${widget.p.costiIndiretti.keys.elementAt(index)}: ${widget.p.costiIndiretti.values.elementAt(index)}'),
                    );
                  }
                )
              ),
              Text('Totale:${n = getSum(widget.p.costiIndiretti.values)}'),
              const SizedBox(height: 20),
            ],
          ),
        ),
    );
  }

  Future getLinesProg() async {
    for(var ref in widget.p.references){
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
    conti = convertMapToObject2(csvData);
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
      'Codice progetto',
      'Project Amounts'
    ];
    list.add(columns);
    int i = 0;
    for (var conto in conti) {
      if(i/29 >= 1){
        list.add(columns);
        list.add(conto.toListFPAmounts(widget.p.nomeProgetto));
        i = 0;
      }
      else{
        list.add(conto.toListFPAmounts(widget.p.nomeProgetto));
        i++;
      }
    }
    return list;
  }

  FutureOr<Uint8List> _generatePdfContent() async{
    final pdf = pw.Document();
    await getLinesProg();
    var tableData = _makeListConti();
    const contentPerPage = 30; // Numero massimo di righe per pagina
    final totalPageCount = (tableData.length / contentPerPage).ceil();
    final image = await imageFromAssetBundle('CeRICT_logo.png');

    pdf.addPage(pw.Page(
      margin: const pw.EdgeInsets.all(3),
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(image, width: 50, height: 50),
                  pw.Text(
                    'Riepilogo Progetto: ${widget.p.nomeProgetto}',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(width: 50), // Placeholder to balance the row
                ],
              ),
              pw.Text('Anno: ${widget.p.anno} | Valore: ${widget.p.valore} | isEconomico: ${widget.p.isEconomico.toString()} | '
                'Contributo di competenza: ${widget.p.contributo}',
              ),
              pw.SizedBox(height: 10),
              pw.Text('Costi Diretti:', textAlign: pw.TextAlign.left),
              pw.ListView.builder(
                itemCount: widget.p.costiDiretti.length,
                itemBuilder: (context, index){
                  return pw.Container(
                    child: pw.Text('${widget.p.costiDiretti.keys.elementAt(index)}: ${widget.p.costiDiretti.values.elementAt(index)}'),
                  );
                }
              ),
              pw.Text('Totale:${n = getSum(widget.p.costiDiretti.values)}'),
              pw.SizedBox(height: 10),
              pw.Text('Costi Indiretti:', textAlign: pw.TextAlign.left),
              pw.ListView.builder(
                itemCount: widget.p.costiIndiretti.length,
                itemBuilder: (context, index){
                  return pw.Container(
                    child: pw.Text('${widget.p.costiIndiretti.keys.elementAt(index)}: ${widget.p.costiIndiretti.values.elementAt(index)}'),
                  );
                }
              ),
              pw.Text('Totale:${n = getSum(widget.p.costiIndiretti.values)}'),
            ],
          )
        );
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
    return pdf.save();
  }

  getCat() async {
    await FirebaseFirestore.instance.collection('categorie').get().then((value) {
      for (var element in value.docs) {
        categories.add(element.id);
      }
    });
  }

  num getSum(Iterable<dynamic> iterable) {
    n = 0;
    for (var element in iterable) {
      n = n + num.parse(element) ;
    }
    n = num.parse(n.toStringAsFixed(2));
    return n;
  }

  Future<void> evaluateWithProgressDialog(String nomeProgetto) async {
    // Esegui il metodo evaluate
    await evaluate(nomeProgetto);
  }

  evaluate(String nomeProgetto) async {
    num s;
    for (var categoria in widget.p.costiDiretti.keys) {
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
      widget.p.costiDiretti.update(categoria, (value) => s.toStringAsFixed(2));
    }
    num totCostiIndAE = 0;
    num totCostiIndAnE = 0;
    DocumentSnapshot riepilogoCatDoc = await FirebaseFirestore.instance.collection('categorie').doc('riepilogoCat').get();
    totCostiIndAE = num.parse(riepilogoCatDoc.get('totCostiIndirettiAttEco').toString());
    totCostiIndAnE = num.parse(riepilogoCatDoc.get('totCostiIndirettiAttNonEco').toString());

    for (var categoria in widget.p.costiIndiretti.keys) {
      s = 0;
      await FirebaseFirestore.instance.collection('categorie').doc(categoria).get().then(
        (cat) {
          if(widget.p.isEconomico){
            s = num.parse(widget.p.perc.toString()) / 100 * totCostiIndAE * num.parse(cat.get('Percentuale CI A E').toString()) / 100;
          }
          else {
            s = num.parse(widget.p.perc.toString()) / 100 * totCostiIndAnE * num.parse(cat.get('Percentuale CI A nE').toString()) / 100;
          }
        }
      );
      widget.p.costiIndiretti.update(categoria, (value) => s.toStringAsFixed(2));
    }
    final json = {
      'Costi Diretti' : widget.p.costiDiretti,
      'Costi Indiretti' : widget.p.costiIndiretti,
      'CostiDirettiValue': documentReferences.map((docRef) => docRef.path).toList(),
    };
    await FirebaseFirestore.instance.collection('progetti').doc(nomeProgetto).update(json);
  }

  deleteProgetto() async {
    await FirebaseFirestore.instance.collection('progetti').doc(widget.p.nomeProgetto).delete();
  }
}