import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
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
  late AppState appState;

  @override
  void initState() {
    super.initState();
    appState = Provider.of<AppState>(context, listen: false);
  }

  Future getConti() async{
    await appState.conti.get().then(
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
    csvData2 = [];
    await appState.conti.doc(idConto).collection('lineeConto').get().then(
      (snapshot) => snapshot.docs.forEach((linea) async{
        Map<String, dynamic> c = linea.data();
        csvData2.add(c);
      })
    );
    conti = convertMapToObject(csvData2);
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
              //await fullcsv(contiRef);
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

FutureOr<Uint8List> _generatePdfContent() async {
  final pdf = pw.Document();
  const contentPerPage = 35; // Numero massimo di righe per pagina
  //final image = await imageFromAssetBundle('CeRICT_logo.png');
  // Load the image as a Uint8List
  final ByteData bytes = await rootBundle.load('assets/images/CeRICT_logo.png');
  final Uint8List imageData = bytes.buffer.asUint8List();
  final image = pw.MemoryImage(imageData);
  // Load the NotoSans font from assets
  final notoSans = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
  final notoSansBold = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));

  int counter = 0;

  for (var ref in contiRef) {
    if (counter >= 5) break;

    await getLines(ref);
    var tableData = _makeListConti();
    final totalPageCount = (tableData.length / contentPerPage).ceil();
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('conti').doc(ref).get();

    // Extract account details
    String codiceConto = documentSnapshot.id;
    String descrizioneConto = documentSnapshot.get('Descrizione conto');
    double saldo = documentSnapshot.get('Saldo');
    double totaleCostiDirettiEconomici = documentSnapshot.get(
        'TotaleCostiDirettiEconomici');
    double totaleCostiDirettiNonEconomici = documentSnapshot.get(
        'TotaleCostiDirettiNonEconomici');
    double totaleCostiIndiretti = documentSnapshot.get('TotaleCostiIndiretti');

    // Add account details page
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(image, width: 80, height: 80), // Add the image
                  pw.SizedBox(width: 5),
                  pw.Text('Riepilogo Conto',
                      style: pw.TextStyle(fontSize: 10, font: notoSans)),
                  pw.SizedBox(width: 5),
                  pw.Text('Documenti Riservati',
                      style: pw.TextStyle(fontSize: 10, font: notoSans)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('$codiceConto $descrizioneConto',
                  style: pw.TextStyle(fontSize: 18,
                      font: notoSansBold)),
              pw.Text('Saldo: $saldo',
                  style: pw.TextStyle(fontSize: 16, font: notoSans)),
              pw.Text(
                  'Totale Costi Diretti Economici: $totaleCostiDirettiEconomici',
                  style: pw.TextStyle(fontSize: 16, font: notoSans)),
              pw.Text(
                  'Totale Costi Diretti Non Economici: $totaleCostiDirettiNonEconomici',
                  style: pw.TextStyle(fontSize: 16, font: notoSans)),
              pw.Text('Totale Costi Indiretti: ${totaleCostiIndiretti
                  .toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 16, font: notoSans)),
            ],
          ),
        );
      },
    ));
    if (saldo != 0) {
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
          cellStyle: pw.TextStyle(fontSize: 4, font: notoSans),
          headerStyle: pw.TextStyle(fontSize: 4, font: notoSansBold),
        );

        pdf.addPage(pw.Page(
          orientation: pw.PageOrientation.landscape,
          margin: const pw.EdgeInsets.all(3),
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Padding( // Aggiunto il widget Padding
                  padding: const pw.EdgeInsets.all(10),
                  // Aggiunto un margine di 10
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
        ));
      }
    }
    counter++;
  }
  return pdf.save();
}

  List<List<dynamic>> _makeListConti() {
    List<List<dynamic>> list = [];
    final columns = [
      //'Codice Conto',
      //'Descrizione conto',
      'Data operazione',
      'Descrizione operazione',
      'Numero documento',
      'Data documento',
      'Importo',
      //'Saldo',
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
      if(i/34 >= 1){
        list.add(columns);
        list.add(conto.toList());
        i = 0;
      }
      else{
        list.add(conto.toList());
        i++;
      }
    }
    return list;
  }
}