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

  VisualizzaConto({super.key, required this.idConto, required this.descrizioneConto});

  State<VisualizzaConto> createState() => _VisualizzaConto();
}

class _VisualizzaConto extends State<VisualizzaConto> {
  List<Conto> conti = [];
  List<String> lines = [];
  List<Map<String, dynamic>> csvData = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            // Status bar color
            statusBarColor: Colors.white,
            // Status bar brightness (optional)
            statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
          centerTitle: true,
          title: Text(widget.idConto+'   '+widget.descrizioneConto,
              style: TextStyle(color: Colors.white,
                fontSize: 20.0, )
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Modifica'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  ModifyData(csvData: csvData, lines: lines)));
              },
            ),
          ],
        ),
      body: FutureBuilder(future: getLines(widget.idConto),
      builder: (context, snapshot){
        return ScrollableWidget(child: buildDataTable());
      })
    );
  }

   Widget buildDataTable() {
    final columns = [
      'Data operazione',
      'COD',
      'Descrizione operazione',
      'Numero documento',
      'Data documento',
      'NumeroFattura',
      'Importo',
      'Contropartita',
      'Costi diretti',
      'Costi indiretti',
      'Attivita economiche',
      'Attivita non economiche',
      'Codice progetto'
    ];

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
        return DataCell(
          Text('$cell'),
        );
      }),
    );
  }).toList();

  Future getLines(String idConto) async{
    await FirebaseFirestore.instance.collection('conti/$idConto/lineeConto').get().then(
            (snapshot) => snapshot.docs.forEach(
                (linea) {
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
            }
        )
    );
    conti = convertMapToObject(csvData);
  }
}