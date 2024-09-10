import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'modify_data_cat.dart';
import 'scrollable_widget.dart';
import 'conto.dart';
import 'utils.dart';

class ViewContiCatPage extends StatefulWidget {
  String idCat;
  String getidCat() => idCat;

  ViewContiCatPage({super.key, required this.idCat});

  @override
  State<ViewContiCatPage> createState() => _ViewContiCatPage();
}

class _ViewContiCatPage extends State<ViewContiCatPage> {
  List<Conto> contiM = [];
  List<String> lines = [];
  List<Map<String, dynamic>> csvData = [];
  List<dynamic> conti = [];
  final ScrollController _controller = ScrollController();
  late Future bool;
  final columns = [
    'Codice conto',
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
    'CodiceProgetto'
  ];
  String refresh = '';

  @override
  void initState() {
    super.initState();
    getLinesConto().then((_) {
      setState(() {});
    });
  }

  void reload(){
    setState(() {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ViewContiCatPage(idCat: widget.idCat)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness:
            Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        centerTitle: true,
        title: Text(widget.idCat,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20.0,
          )),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Modifica'),
            onPressed: () async{
              String refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => ModifyDataCat(csvData: csvData, lines: lines, idCat: widget.idCat)));
              if (refresh == 'refresh') {
                reload();
              }
            },
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: (){
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
            icon: const Icon(Icons.home)),
          const SizedBox(width: 16),
        ],
      ),
      body: Scrollbar(
        thumbVisibility: true,
        controller: _controller,
        child: ScrollableWidget(controller: _controller, child: buildDataTable()),
      ),
    );
  }

  Widget buildDataTable() {
    return DataTable(
      columns: getColumns(columns),
      rows: getRows(contiM),
    );
  }

  List<DataColumn> getColumns(List<String> columns) {
    return columns.map(
      (item) => DataColumn(
        label: Text(
          item.toString(),
        ),
      ),
    ).toList();
  }

  List<DataRow> getRows(List<Conto> conti) {
    return conti.map((Conto conto) {
      final cells = [
        conto.codiceConto,
        conto.descrizioneConto,
        conto.dataOperazione,
        conto.descrizioneOperazione,
        conto.numeroDocumento,
        conto.dataDocumento,
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
          if (index == 9) {
            switch (conto.costiDiretti) {
              case true:
                return const DataCell(Center(
                  child: Tooltip(message: 'Costi diretti', child: Icon(Icons.check))
                ));
              case false:
                return const DataCell(Center(
                  child: Tooltip(message: 'Costi diretti', child: Icon(Icons.clear))
                ));
            }
          }
          if (index == 10) {
            switch (conto.costiIndiretti) {
              case true:
                return const DataCell(Center(
                  child: Tooltip(message: 'Costi indiretti', child: Icon(Icons.check))
                ));
              case false:
                return const DataCell(Center(
                  child: Tooltip(message: 'Costi indiretti', child: Icon(Icons.clear))
                ));
            }
          }
          if (index == 11) {
            switch (conto.attivitaEconomiche) {
              case true:
                return const DataCell(Center(
                  child: Tooltip(message: 'Attività economiche', child: Icon(Icons.check))
                ));
              case false:
                return const DataCell(Center(
                  child: Tooltip(message: 'Attività economiche', child: Icon(Icons.clear))
                ));
            }
          }
          if (index == 12) {
            switch (conto.attivitaNonEconomiche) {
              case true:
                return const DataCell(Center(
                  child: Tooltip(message: 'Attività non economiche', child: Icon(Icons.check))
                ));
              case false:
                return const DataCell(Center(
                  child: Tooltip(message: 'Attività non economiche', child: Icon(Icons.clear))
                ));
            }
          }
          if (index == 13) {
            if (widget.idCat == 'Personale') {
              return DataCell(
                ElevatedButton(
                  onPressed: () async {
                    await viewProjectAmounts(conto, lines[conti.indexOf(conto)]);
                  },
                  child: const Text('Visualizza Progetti'),
                ),
              );
            } else {
              return DataCell(Tooltip(
                message: testo(index),
                child: Text('$cell'),
              ));
            }
          }
          return DataCell(Tooltip(
            message: testo(index),
            child: Text('$cell'),
          ));
        }),
      );
    }).toList();
  }

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
    if (i == 8) return columns[i];
    if (i == 13) return columns[i];
    return testo;
  }

  Future<LinkedHashMap<String, double>> fetchProjectAmounts(Conto c, String lineaC) async {
    LinkedHashMap<String, double> projectAmounts = LinkedHashMap<String, double>();

    // Find the matching element in conti
    DocumentReference? matchingElement;
    for (var idC in conti) {
      DocumentReference s = idC as DocumentReference;
      if (s.id == c.codiceConto) {
        matchingElement = s;
        break;
      }
    }
    Map<String, dynamic> data = {};
    if (matchingElement != null) {
      await FirebaseFirestore.instance.collection('conti/${matchingElement.id}/lineeConto').get().then(
        (snapshot) => snapshot.docs.forEach((linea) {
          if (linea.id == lineaC) {
            data = linea.data();
            if (data['Project Amounts'] is LinkedHashMap) {
              projectAmounts = LinkedHashMap<String, double>.from(data['Project Amounts'].map((key, value) => MapEntry(key, value.toDouble())));
            }
          }
        })
      );
    }
    return projectAmounts;
  }

  Future<void> viewProjectAmounts(Conto conto, String rowIndex) async {
    LinkedHashMap<String, double> projectAmounts = await fetchProjectAmounts(conto, rowIndex);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Visualizza Progetti'),
          content: SingleChildScrollView(
            child: Column(
              children: projectAmounts.keys.map((String key) {
                return ListTile(
                  title: Text(key),
                  subtitle: Text('Importo: ${projectAmounts[key]}'),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future getLinesConto() async {
    await findConti(widget.idCat);
    for (var idC in conti) {
      DocumentReference s = idC as DocumentReference;
      await FirebaseFirestore.instance.collection('conti/${s.id}/lineeConto').get().then(
        (snapshot) => snapshot.docs.forEach((linea) {
          Map<String, dynamic> c = linea.data();
          lines.add(linea.id);
          csvData.add(c);
        })
      );
    }
    contiM = convertMapToObject2(csvData);
    await valuateTot();
    await valuatePerc();
  }

  Future findConti(String idcat) async {
    await FirebaseFirestore.instance.collection('categorie').get().then(
      (snapshot) => snapshot.docs.forEach((cat) {
        if (cat.id == idcat) {
          conti = cat.get('Conti') as List<dynamic>;
        }
      })
    );
  }

  num totIndiretti = 0;

  Future<void> valuateTot() async {
    totIndiretti = 0;
    num totInnE = 0;
    num totInE = 0;
    num totDnE = 0;
    num totDE = 0;
    num totD = 0;
    num percDE = 0;
    num percDnE = 0;
    DocumentReference d = FirebaseFirestore.instance.collection('categorie').doc(widget.idCat);
    for(var linea in contiM){
      if(linea.costiIndiretti){
        if(!linea.attivitaNonEconomiche && !linea.attivitaEconomiche){
          totIndiretti = totIndiretti + num.parse(linea.importo);
        }
      }
      if(linea.costiDiretti){
        if(linea.attivitaNonEconomiche) {
          totDnE = totDnE + num.parse(linea.importo);
        }
        if(linea.attivitaEconomiche){
          totDE = totDE + num.parse(linea.importo);
        }
      }
    }
    if(totDnE != 0 && totDE != 0){
      totD = totDE + totDnE;
      percDE = 100 * totDE/totD;
      percDnE = 100 * totDnE/totD;
      totInE = totIndiretti * percDE / 100;
      totInnE = totIndiretti * percDnE / 100;
    }
    else{
      totInE = totIndiretti * 0.1;
      totInnE = totIndiretti * 0.9;
    }
    final json = {
      'Totale Costi Diretti A E' : totDE,
      'Totale Costi Diretti A nE' : totDnE,
      'Totale Costi Indiretti A E' : totInE,
      'Totale Costi Indiretti A nE' : totInnE,
    };
    d.update(json);
  }

  Future<void> valuatePerc() async {
    num percCIAE = 0;
    num percCIAnE = 0;
    num totCIAE = 0;
    num totCIAnE = 0;
    CollectionReference c =  FirebaseFirestore.instance.collection('categorie');
    totCIAE = 0;
    totCIAnE = 0;
    await FirebaseFirestore.instance.collection('categorie').get().then(
      (snapshot) => snapshot.docs.forEach(
        (cat) {
          totCIAE = totCIAE + num.parse(cat.get('Totale Costi Indiretti A E').toString());
          totCIAnE = totCIAnE + num.parse(cat.get('Totale Costi Indiretti A nE').toString());
        }
      )
    );
    c.get().then(
      (snapshot) => snapshot.docs.forEach(
        (cat) {
          var sTotCIAE = cat.get('Totale Costi Indiretti A E').toString();
          var sTotCIAnE = cat.get('Totale Costi Indiretti A nE').toString();
          percCIAE = 0;
          percCIAnE = 0;
          percCIAE = 100 * (num.parse(sTotCIAE)/totCIAE);
          percCIAnE = 100 * (num.parse(sTotCIAnE)/totCIAnE);
          final json = {
            'Percentuale CI A E' : percCIAE.toStringAsFixed(2),
            'Percentuale CI A nE' : percCIAnE.toStringAsFixed(2)
          };
          c.doc(cat.id).update(json);
        }
      )
    );
  }
}