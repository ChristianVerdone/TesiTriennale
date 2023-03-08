import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import '../ModifyData.dart';
import '../Widget/ScrollableWidget.dart';
import '../model/Conto.dart';
import '../utils.dart';

class ViewContiCatPage extends StatefulWidget {
  String idCat;

  ViewContiCatPage({super.key, required this.idCat});

  @override
  State<ViewContiCatPage> createState() => _ViewContiCatPage();
}

class _ViewContiCatPage extends State<ViewContiCatPage> {
  List<Conto> contiM = [];
  List<String> lines = [];
  List<Map<String, dynamic>> csvData = [];
  List<dynamic> conti = [];

  @override
  void initState() {
    super.initState();
  }

  String refresh = '';
  void reload(){
    setState(() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ViewContiCatPage(idCat: widget.idCat),
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
          title: Text(widget.idCat,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              )),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Modifica'),
              onPressed: () async{
                String refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ModifyData(csvData: csvData, lines: lines)));
                if (refresh == 'refresh') {
                  reload();
                }
              },
            ),
          ],
        ),
        body: FutureBuilder(
            future: getLinesConto(),
            builder: (context, snapshot) {
              return ScrollableWidget(child: buildDataTable());
            }));
  }

  Widget buildDataTable() {
    final columns = [
      'CodiceConto',
      'DescrizioneConto',
      'DataOperazione',
      'COD',
      'DescrizioneOperazione',
      'NumeroDocumento',
      'DataDocumento',
      'NumeroFattura',
      'Importo',
      'Saldo',
      'Contropartita',
      'CostiDiretti',
      'CostiIndiretti',
      'AttivitaEconomiche',
      'AttivitaNonEconomiche',
      'CodiceProgetto'
    ];

    return DataTable(
      columns: getColumns(columns),
      rows: getRows(contiM),
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
          conto.codiceConto,
          conto.descrizioneConto,
          conto.dataOperazione,
          conto.COD,
          conto.descrizioneOperazione,
          conto.numeroDocumento,
          conto.dataDocumento,
          conto.numeroFattura,
          conto.importo,
          conto.saldo,
          conto.contropartita,
          conto.costiDiretti,
          conto.costiIndiretti,
          conto.attivitaEconomiche,
          conto.attivitaNonEconomiche,
          conto.codiceProgetto
        ];

        return DataRow(
          cells: Utils.modelBuilder(cells, (index, cell) {
            if (index == 11) {
              switch (conto.costiDiretti) {
                case true:
                  return const DataCell(Center(child: Icon(Icons.check)));
                case false:
                  return const DataCell(Center(child: Icon(Icons.clear)));
              }
            }
            if (index == 12) {
              switch (conto.costiIndiretti) {
                case true:
                  return const DataCell(Center(child: Icon(Icons.check)));
                case false:
                  return const DataCell(Center(child: Icon(Icons.clear)));
              }
            }
            if (index == 13) {
              switch (conto.attivitaEconomiche) {
                case true:
                  return const DataCell(Center(child: Icon(Icons.check)));
                case false:
                  return const DataCell(Center(child: Icon(Icons.clear)));
              }
            }
            if (index == 14) {
              switch (conto.attivitaNonEconomiche) {
                case true:
                  return const DataCell(Center(child: Icon(Icons.check)));
                case false:
                  return const DataCell(Center(child: Icon(Icons.clear)));
              }
            }
            return DataCell(
              Text('$cell'),
            );
          }),
        );
      }).toList();

  Future getLinesConto() async {
    await findConti(widget.idCat);
    for (var idC in conti) {
      DocumentReference s = idC as DocumentReference;
      await FirebaseFirestore.instance
          .collection('conti/${s.id}/lineeConto')
          .get()
          .then((snapshot) => snapshot.docs.forEach((linea) {
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
                  'Attività non economiche':
                      linea.get('Attività non economiche'),
                  'Codice progetto': linea.get('Codice progetto')
                };
                lines.add(linea.id);
                csvData.add(c);
                //print(csvData);
              }));
    }
    contiM = convertMapToObject(csvData);
    valuateTot();
  }

  Future findConti(String idcat) async {
    await FirebaseFirestore.instance
        .collection('categorie')
        .get()
        .then((snapshot) => snapshot.docs.forEach((cat) {
              if (cat.id == idcat) {
                conti = cat.get('Conti') as List<dynamic>;
              }
            }));
  }

  Future<void> valuateTot() async {
    num totIn = 0;
    for (var linea in contiM) {
      if (linea.costiIndiretti == true) {
        totIn = totIn + num.parse(linea.importo);
      }
    }
    DocumentReference d =
        FirebaseFirestore.instance.collection('categorie').doc(widget.idCat);
    d.get().then((cat) {
      if (cat.get('Totale Costi Indiretti') != totIn.toString()) {
        final json = {
          'Conti': cat.get('Conti'),
          'Totale Costi Diretti': '0',
          'Totale Costi Indiretti': totIn.toString()
        };
        d.set(json);
      }
    });
  }
}
