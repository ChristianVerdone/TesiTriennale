import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../model/Conto.dart';
import '../readData/getConto.dart';
import '../utils.dart';
import 'viewcategorie.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../readData/getConto.dart';
import 'viewcategorie.dart';

class VisualizzaPage extends StatefulWidget { //seconda page di caricamento di dati dal database
  VisualizzaPage({super.key,});
  @override
  State<VisualizzaPage> createState() => _VisualizzaPageState();
}

class _VisualizzaPageState extends State<VisualizzaPage>{
  List<Map<String, dynamic>> csvData2 = [];
  List<Conto> conti = [];
  List<String> contiRef = [];
  final columns = ['Codice Conto', 'Descrizione Conto'
    'Data operazione',
    'COD',
    'Descrizione operazione',
    'Numero documento',
    'Data documento',
    'Numero fattura',
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
                  if(!(contiRef.contains(conto.reference.id))){
                    contiRef.add(conto.reference.id);
                  }
                }
            )
    );
  }

  fullcsv(List<dynamic> contiref) async {
    for (var ref in contiRef) {
      print(ref);
      getLines(ref);
    }
    conti = convertMapToObject(csvData2);
  }

  Future getLines(String idConto) async {
    await FirebaseFirestore.instance
        .collection('conti/$idConto/lineeConto')
        .get()
        .then((snapshot) =>
        snapshot.docs.forEach((linea) async{
      print(linea.reference);
      Map<String, dynamic> c = {
        'Codice Conto': linea.get('Codice Conto'),
        'Descrizione conto': linea.get('Descrizione conto'),
        'Data operazione': linea.get('Data operazione'),
        'COD': linea.get('COD'),
        'Descrizione operazione': linea.get('Descrizione operazione'),
        'Numero documento': linea.get('Numero documento'),
        'Data documento': linea.get('Data documento'),
        'Numero Fattura': linea.get('Numero Fattura'),
        'Importo': linea.get('Importo'),
        'Saldo': linea.get('Saldo'),
        'Contropartita': linea.get('Contropartita'),
        'Costi Diretti': linea.get('Costi Diretti'),
        'Costi Indiretti': linea.get('Costi Indiretti'),
        'Attività economiche': linea.get('Attività economiche'),
        'Attività non economiche': linea.get('Attività non economiche'),
        'Codice progetto': linea.get('Codice progetto')
      };
      print(c);
      csvData2.add(c);
      print(csvData2);
    }));
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
              // Navigate to second route when tapped.
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VisualizzaCatPage()));
            },
          ),
          FloatingActionButton(
            onPressed: () async {
              await fullcsv(contiRef);
              Printing.layoutPdf(onLayout: (format) => _generatePdfContent());
            },
            child: Icon(Icons.print),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: FutureBuilder(
                    future: getConti(),
                    builder: (context, snapshot){
                      return ListView.builder(
                          itemCount: contiRef.length,
                          itemBuilder: (context, index){
                            return ListTile(
                              title: GetConto(idConto: contiRef[index]),
                            );
                          });
                    })
            )
          ],
        ),
      ),
    );
  }

  FutureOr<Uint8List> _generatePdfContent() async{
    final pdf = pw.Document();
    var tableData = _makeListConti();
    final table = pw.TableHelper.fromTextArray(
      data: tableData,
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(5),
      headerDecoration: const pw.BoxDecoration(
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
        color: PdfColors.grey,
      ),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
      },
    );

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Container(
          child: table,
        );
      },
    ));

    return pdf.save();
  }

  List<List<dynamic>> _makeListConti() {
    List<List<dynamic>> list = [];
    
    list.add(columns);
    for (var conto in conti) {
      list.add(conto.toList());
    }
    return list;
  }

}