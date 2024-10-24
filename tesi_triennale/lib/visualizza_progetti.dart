import 'dart:async';
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
  List<String> progetti = [];
  List<Map<String, dynamic>> csvData = [];
  List<Conto> conti = [];
  num n = 0;
  String refresh = '';

  @override
  void initState() {
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
    valuatetot();
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
          ]
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: FutureBuilder(
                future: getProgetti(),
                builder: (context, snapshot){
                  return ListView.builder(
                    itemCount: progetti.length,
                    itemBuilder: (context, index){
                      return ListTile(
                        title: GetProgetto(idProg: progetti[index]),
                      );
                    }
                  );
                }
              )
            )
          ],
        ),
      ),
    );
  }

  Future getProgetti() async{
    num perc = 0;
    await FirebaseFirestore.instance.collection('progetti').get().then(
      (snapshot) => snapshot.docs.forEach(
        (progetto) {
          if(progetto.reference.id != 'DefaultProject'){
            if(!(progetti.contains(progetto.reference.id))){
              progetti.add(progetto.reference.id);
            }
            if(progetto.get('isEconomico')){
              perc = (num.parse(progetto.get('Contributo Competenza').toString()) / totProgettiE) * 100;
            }
            else{
              perc = (num.parse(progetto.get('Contributo Competenza').toString()) / totProgettinE) * 100;
            }
            final json = {
              'Percentuale' : perc.toStringAsFixed(2),
            };
            progetto.reference.update(json);
          }
          perc = 0;
        }
      )
    );
  }

  Future<void> valuatetot() async {
    await FirebaseFirestore.instance.collection('progetti').get().then(
      (snap) => snap.docs.forEach(
        (progetto) {
          if(progetto.reference.id != 'DefaultProject'){
            if(progetto.get('isEconomico')){
              totProgettiE = totProgettiE + num.parse(progetto.get('Contributo Competenza').toString());
            }
            else{
              totProgettinE = totProgettinE + num.parse(progetto.get('Contributo Competenza').toString());
            }
          }
        }
      )
    );
    final json = {
      'totProgettiE': totProgettiE,
      'totProgettinE': totProgettinE,
    };
    await FirebaseFirestore.instance.collection('categorie').doc('Valore della Produzione').set(json,
        SetOptions(merge: true));
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
}