import 'dart:async';
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
              await deleteProgetto();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VisualizzaProg()));
            },
            icon: const Icon(Icons.remove)),
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
          ElevatedButton(
            onPressed: () async {
              await evaluateWithProgressDialog(widget.p.nomeProgetto);
              Navigator.of(context).pop(true);
            },
            child: const Text('Calcola costi')
          )
        ],
        centerTitle: true,
        title: Text('Visualizzazione Progetto: ${widget.p.nomeProgetto}',
            style: const TextStyle(color: Colors.black, fontSize: 20.0)
        ),
      ),
      body: FutureBuilder(
        future: getCat(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
          return Center(
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
          );
          }
          return const Center(child: Text('loading...'));
        },
      )
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
    final pdf = pw.Document();
    await getLinesProg();
    var tableData = _makeListConti();
    const contentPerPage = 20; // Numero massimo di righe per pagina
    final totalPageCount = (tableData.length / contentPerPage).ceil();

    pdf.addPage(pw.Page(
      margin: const pw.EdgeInsets.all(3),
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Column(
            children: [
              pw.Text('${widget.p.nomeProgetto}'),
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
    return n;
  }

  Future<void> evaluateWithProgressDialog(String nomeProgetto) async {
  // Mostra il dialogo con il CircularProgressIndicator
  showDialog(
    context: context,
    barrierDismissible: false, // Impedisce di chiudere il dialogo cliccando fuori
    builder: (BuildContext context) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Caricamento..."),
            ],
          ),
        ),
      );
    },
  );
  // Esegui il metodo evaluate
  await evaluate(nomeProgetto);
  // Chiudi il dialogo una volta completato
  Navigator.of(context).pop(true);
}

  evaluate(String nomeProgetto) async {
    // Crea un array di DocumentReference
    List<DocumentReference> documentReferences = [];
    num s;
    for (var categoria in widget.p.costiDiretti.keys) {
      s = 0;
      await FirebaseFirestore.instance.collection('categorie').doc(categoria).get().then(
        (cat) async {
          for (var element in (cat.get('Conti') as List<dynamic>)){
            DocumentReference d = element as DocumentReference;
            if (kDebugMode) {
              print(d.id);
            }
            await FirebaseFirestore.instance.collection('conti/${d.id}/lineeConto').get().then(
              (value) => value.docs.forEach(
                (linea) {
                  if(linea.reference.id != 'defaultLine'){
                    var c = linea.data()['Codice progetto'].toString();
                    if(c == nomeProgetto && linea.get('Costi Diretti') == true){
                      s = s + num.parse(linea.get('Importo').toString());
                      // Aggiungi il DocumentReference all'array
                      documentReferences.add(linea.reference);
                      if (kDebugMode) {
                        print(linea.reference.id);
                      }
                    }
                  }
                }
              )
            );
          }
        }
      );
      widget.p.costiDiretti.update(categoria, (value) => s.toStringAsFixed(2));
    }
    num totCostiIndAE = 0;
    num totCostiIndAnE = 0;
    await FirebaseFirestore.instance.collection('categorie').get().then(
      (snap) => snap.docs.forEach(
        (cat) {
          totCostiIndAE = totCostiIndAE + num.parse(cat.get('Totale Costi Indiretti A E').toString());
          totCostiIndAnE = totCostiIndAnE + num.parse(cat.get('Totale Costi Indiretti A nE').toString());
        }
      )
    );
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