import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'conto.dart';
import 'get_conto.dart';
import 'utils.dart';
import 'view_categorie.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class VisualizzaPage extends StatefulWidget { //seconda page di caricamento di dati dal database
  const VisualizzaPage({super.key,});
  @override
  State<VisualizzaPage> createState() => _VisualizzaPageState();
}

class _VisualizzaPageState extends State<VisualizzaPage>{
  List<Map<String, dynamic>> csvData2 = [];
  List<Conto> conti = [];
  List<String> contiRef = [];
  final columns = [
    'Codice Conto',
    'Descrizione Conto'
    'Data operazione',
    'Descrizione operazione',
    'Numero documento',
    'Data documento',
    'Importo',
    'Contropartita',
    'Costi diretti',
    'Costi indiretti',
    'Attivita economiche',
    'Attivita non economiche',
    'Codice progetto'
  ];

  @override
  void initState() {
    super.initState();
  }

  Future getConti() async{
    await FirebaseFirestore.instance.collection('conti').get().then(
      (snapshot) => snapshot.docs.forEach(
        (conto) async {
          if(conto.reference.id != 'Codice Conto'){
            if(!(contiRef.contains(conto.reference.id))){
              contiRef.add(conto.reference.id);
            }
          }
        }
      )
    );
  }

  fullcsv(List<dynamic> contiref) async {
    for (var ref in contiRef) {
      getLines(ref);
    }
    conti = convertMapToObject(csvData2);
  }

  Future getLines(String idConto) async {
    await FirebaseFirestore.instance.collection('conti/$idConto/lineeConto').get().then(
      (snapshot) => snapshot.docs.forEach((linea) async{
        Map<String, dynamic> c = linea.data();
        csvData2.add(c);
        if (kDebugMode) {
          print(csvData2);
        }
      })
    );
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
        title: const Text('Conti'),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Mostra Categorie'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VisualizzaCatPage()));
            },
          ),
          FloatingActionButton(
            onPressed: () async {
              await fullcsv(contiRef);
              Printing.layoutPdf(onLayout: (format) => _generatePdfContent());
            },
            child: const Icon(Icons.print),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: FutureBuilder(
                future: getConti(), //richiamo la funzione getConti
                builder: (context, snapshot){
                  return ListView.builder(itemCount: contiRef.length,
                    itemBuilder: (context, index){
                      return ListTile(
                        title: GetConto(idConto: contiRef[index]),
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

  FutureOr<Uint8List> _generatePdfContent() async{
    final pdf = pw.Document();
    var tableData = _makeListConti();
    const contentPerPage = 20; // Numero massimo di righe per pagina
    final totalPageCount = (tableData.length / contentPerPage).ceil();
    for (int pageIndex = 0; pageIndex < totalPageCount; pageIndex++) {
      final startIndex = pageIndex * contentPerPage;
      final endIndex = (pageIndex + 1) * contentPerPage;
      final currentPageData = tableData.sublist(startIndex,
          endIndex > tableData.length ? tableData.length : endIndex);
      final table = pw.TableHelper.fromTextArray(
          data: currentPageData,
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(5),
          headerDecoration: const pw.BoxDecoration(
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
            color: PdfColors.grey,
          ),
        cellStyle: pw.TextStyle(fontSize: 4,font: pw.Font.times()),
        headerStyle: pw.TextStyle(fontSize: 4, font: pw.Font.helvetica()),
      );

      pw.Page p = pw.Page(
        orientation: pw.PageOrientation.landscape,
        margin: const pw.EdgeInsets.all(3),
        build: (pw.Context context) {
          return pw.Center(
              child: pw.Container(
                child: table,
              )
          );
        },
      );
      pdf.addPage(p, index: pageIndex,);
    }
    return pdf.save();
  }

  List<List<dynamic>> _makeListConti() {
    List<List<dynamic>> list = [];
    final columns = [
      'Codice Conto',
      'Descrizione conto',
      'Data operazione',
      'Descrizione operazione',
      'Numero documento',
      'Data documento',
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
        list.add(conto.toList());
        list.add(columns);
      }
      else{
        list.add(conto.toList());
      }
    }
    return list;
  }
}