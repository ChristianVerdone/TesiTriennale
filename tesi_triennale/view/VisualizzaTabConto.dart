import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import '../ModifyData.dart';
import '../Widget/ScrollableWidget.dart';
import '../model/Conto.dart';
import '../utils.dart';

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
    'Attivita economiche',
    'Attivita non economiche',
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
          title: Text(widget.idConto + '   ' + widget.descrizioneConto,
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
            SizedBox(width: 16),
            FloatingActionButton(
              onPressed: () {
                Printing.layoutPdf(onLayout: (pageFormat) {
                  final doc = pw.Document();
                  doc.addPage(pw.Page(
                    build: (context) => Center(
                      child: Text('Hello, World!'),
                    ),
                  ));
                  return doc.save();
                });
              },
              child: Icon(Icons.print),
            ),
            IconButton(
                onPressed: (){
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                icon: const Icon(Icons.home)),
            SizedBox(width: 16),
          ],
        ),
        body: FutureBuilder(
            future: getLines(widget.idConto),
            builder: (context, snapshot) {
              return ScrollableWidget(child: buildDataTable());
            }));
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
