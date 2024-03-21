import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, Uint8List;
import 'ModifyData.dart';
import 'ScrollableWidget.dart';
import 'Conto.dart';
import 'utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class VisualizzaConto extends StatefulWidget {
  String idConto;
  String descrizioneConto;

  VisualizzaConto(
      {super.key, required this.idConto, required this.descrizioneConto});

  @override
  State<VisualizzaConto> createState() => _VisualizzaConto();
}

class _VisualizzaConto extends State<VisualizzaConto> {
  List<Conto> conti = [];
  List<String> lines = [];
  List<Map<String, dynamic>> csvData = [];

  final columns = [
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
    'Attività economiche',
    'Attività non economiche',
    'Codice progetto'
  ];

  @override
  void initState() {
    super.initState();
  }

  void reload(){
    setState(() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => VisualizzaConto(
              idConto: widget.idConto,
              descrizioneConto: widget.descrizioneConto),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            // Status bar color
            statusBarColor: Colors.white,
            // Status bar brightness (optional)
            statusBarIconBrightness:
            Brightness.dark, // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
          centerTitle: true,
          title: Text('${widget.idConto}   ${widget.descrizioneConto}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              )),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Modifica'),
              onPressed: () async {
                String refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        //FixedHeaderDataTable(columns: columns, rows: rows)));
                        ModifyData(csvData: csvData, lines: lines)));
                if (refresh == 'refresh') {
                  reload();
                }
              },
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
          ],
        ),
        body: FutureBuilder(
            future: getLines(widget.idConto),
            builder: (context, snapshot) {
              return ScrollableWidget(child: buildDataTable());
            }));
  }

  FutureOr<Uint8List> _generatePdfContent() async{
    final pdf = pw.Document();
    var tableData = _makeListConti();

    const contentPerPage = 15; // Numero massimo di righe per pagina
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
          cellStyle: pw.TextStyle(fontSize: 8,font: pw.Font.timesItalic()),
          headerStyle: pw.TextStyle(fontSize: 8, font: pw.Font.timesItalic())
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
      'COD',
      'Descrizione operazione',
      'Numero documento',
      'Data documento',
      'Numero fattura',
      'Importo',
      'Saldo',
      'Contropartita',
      'Costi diretti',
      'Costi indiretti',
      'Attività economiche',
      'Attività non economiche',
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

  Widget buildDataTable() {
    return DataTable(
      columns: getColumns(columns),
      rows: getRows(conti),
    );
  }

  List<DataColumn> getColumns(List<String> columns) {
    return columns
        .map(
          (item) => DataColumn(
        label: Text(
          item.toString(),
        ),
      ),
    )
        .toList();
  }

  List<DataRow> getRows(List<Conto> conti) => conti.map((Conto conto) {
    final cells = [
      conto.dataOperazione,
      conto.COD,
      conto.descrizioneOperazione,
      conto.numeroDocumento,
      conto.dataDocumento,
      conto.numeroFattura,
      conto.importo,
      conto.contropartita,
      conto.costiDiretti,
      conto.costiIndiretti,
      conto.attivitaEconomiche,
      conto.attivitaNonEconomiche,
      conto.codiceProgetto
    ];

    return DataRow(
      cells: Utils.modelBuilder(cells, (index, cell) {
        if (index == 8) {
          switch (conto.costiDiretti) {
            case true:
              return const DataCell(Center(
                  child: Tooltip(
                      message: 'Costi diretti', child: Icon(Icons.check))));
            case false:
              return const DataCell(Center(
                  child: Tooltip(
                      message: 'Costi diretti', child: Icon(Icons.clear))));
          }
        }
        if (index == 9) {
          switch (conto.costiIndiretti) {
            case true:
              return const DataCell(Center(
                  child: Tooltip(
                      message: 'Costi indiretti', child: Icon(Icons.check))));
            case false:
              return const DataCell(Center(
                  child: Tooltip(
                      message: 'Costi indiretti', child: Icon(Icons.clear))));
          }
        }
        if (index == 10) {
          switch (conto.attivitaEconomiche) {
            case true:
              return const DataCell(Center(
                  child: Tooltip(
                      message: 'Attività economiche', child: Icon(Icons.check))));
            case false:
              return const DataCell(Center(
                  child: Tooltip(
                      message: 'Attività economiche', child: Icon(Icons.clear))));
          }
        }
        if (index == 11) {
          switch (conto.attivitaNonEconomiche) {
            case true:
              return const DataCell(Center(
                  child: Tooltip(
                      message: 'Attività non economiche', child: Icon(Icons.check))));
            case false:
              return const DataCell(Center(
                  child: Tooltip(
                      message: 'Attività non economiche', child: Icon(Icons.clear))));
          }
        }
        return DataCell(Tooltip(
          message: testo(index),
          child: Text(
            '$cell',
          ),
        ));
      }),
    );
  }).toList();

  String testo(int i) {
    String testo = '';
    if (i == 0) return columns[i];
    if (i == 1) return columns[i];
    if (i == 2) return columns[i];
    if (i == 3) return columns[i];
    if (i == 4) return columns[i];
    if (i == 5) return columns[i];
    if (i == 6) return columns[i];
    if (i == 7) return columns[i];
    if (i == 12) return columns[i];

    return testo;
  }

  Future getLines(String idConto) async {
    await FirebaseFirestore.instance
        .collection('conti/$idConto/lineeConto')
        .get()
        .then((snapshot) => snapshot.docs.forEach((linea) {
      //print(linea.reference);
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
      lines.add(linea.id);
      csvData.add(c);
      //print(csvData);
    }));
    conti = convertMapToObject(csvData);
  }
}