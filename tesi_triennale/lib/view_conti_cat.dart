import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:provider/provider.dart';
import 'app_state.dart';
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
    'Codice Fiscale',
    'Partita IVA',
    'Contropartita',
    'Costi diretti',
    'Costi indiretti',
    'Attività economiche',
    'Attività non economiche',
    'Codice progetto'
  ];
  String refresh = '';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  num saldo = 0;
  num totaleCostiDirettiAE = 0;
  num totaleCostiDirettiAnE = 0;
  num totaleCostiIndirettiAE = 0;
  num totaleCostiIndirettiAnE = 0;

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Saldo: $saldo'),
                Text('Totale Costi Diretti Attivit\u00E0 Economica: $totaleCostiDirettiAE'),
                Text('Totale Costi Diretti Attivit\u00E0 non Economica: $totaleCostiDirettiAnE'),
                Text('Totale Costi Indiretti Attivit\u00E0 Economica: $totaleCostiIndirettiAE'),
                Text('Totale Costi Indiretti Attivit\u00E0 non Economica: $totaleCostiIndirettiAnE'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              controller: _controller,
              child: ScrollableWidget(controller: _controller, child: buildDataTable()),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDataTable() {
    final filteredConti = filterConti(contiM, _searchQuery);
    return DataTable(
      columns: getColumns(columns),
      rows: getRows(filteredConti),
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
        conto.codiceFiscale,
        conto.partitaIva,
        conto.contropartita,
        conto.costiDiretti,
        conto.costiIndiretti,
        conto.attivitaEconomiche,
        conto.attivitaNonEconomiche,
        conto.codiceProgetto
      ];

      return DataRow(
        color: conto.costiDiretti ? MaterialStateProperty.all(Colors.blue) : null,
        cells: Utils.modelBuilder(cells, (index, cell) {
          if (index == 10) {
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
          if (index == 11) {
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
          if (index == 12) {
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
          if (index == 13) {
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
          if (index == 14) {
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
    if (i == 9) return columns[i];
    if (i == 14) return columns[i];
    return testo;
  }

  Future<LinkedHashMap<String, double>> fetchProjectAmounts(Conto c, String lineaC) async {
    final appState = Provider.of<AppState>(context, listen: false);
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
      await appState.conti.doc(matchingElement.id).collection('lineeConto').get().then(
              (snapshot) => snapshot.docs.forEach((linea) {
            if (linea.id == lineaC) {
              data = linea.data();
              if (data['Project Amounts'] is LinkedHashMap) {
                projectAmounts = LinkedHashMap<String, double>.from(data['Project Amounts'].map((key, value) => MapEntry(key, value.toDouble())));
              }
            }
          }));
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
    final appstate = Provider.of<AppState>(context, listen: false);
    await findConti(widget.idCat);
    for (var idC in conti) {
      DocumentReference s = idC as DocumentReference;
      await appstate.conti.doc(s.id).collection('lineeConto').get().then(
              (snapshot) => snapshot.docs.forEach((linea) {
            if (linea.reference.id != 'defaultLine') {
              Map<String, dynamic> c = linea.data();
              lines.add(linea.id);
              csvData.add(c);
            }
          }));
    }
    contiM = convertMapToObject2(csvData);
    await valuateTot();
    await valuatePerc();
  }

  Future findConti(String idcat) async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.categorie.get().then(
            (snapshot) => snapshot.docs.forEach((cat) {
          if (cat.id == idcat) {
            conti = cat.get('Conti');
          }
        }));
    for (var conto in conti) {
      DocumentReference s = conto as DocumentReference;
      calcolaSommaImporti(context, s.id);
    }
  }

  num totIndiretti = 0;

  Future<Map<String, dynamic>> getContoAttributes(String id) async {
    final appState = Provider.of<AppState>(context, listen: false);
    DocumentSnapshot documentSnapshot = await appState.conti.doc(id).get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      return {
        'Saldo': data['Saldo'],
        'TotaleCostiDirettiEconomici': data['TotaleCostiDirettiEconomici'],
        'TotaleCostiDirettiNonEconomici': data['TotaleCostiDirettiNonEconomici'],
        'TotaleCostiIndiretti': data['TotaleCostiIndiretti'],
      };
    } else {
      return {};
    }
  }

  Future<void> valuateTot() async {
    final appState = Provider.of<AppState>(context, listen: false);
    totIndiretti = 0;
    num totInnE = 0;
    num totInE = 0;
    num totDnE = 0;
    num totDE = 0;
    num totD = 0;
    num percDE = 0;
    num percDnE = 0;
    num totSaldo = 0;
    DocumentReference d = appState.categorie.doc(widget.idCat);
    for (var conto in conti) {
      DocumentReference s = conto as DocumentReference;
      var attributes = await getContoAttributes(s.id);
      if(attributes.isEmpty) {
        continue;
      }
      num saldo = attributes['Saldo'];
      num totaleCostiDirettiEconomici = attributes['TotaleCostiDirettiEconomici'];
      num totaleCostiDirettiNonEconomici = attributes['TotaleCostiDirettiNonEconomici'];
      num totaleCostiIndiretti = attributes['TotaleCostiIndiretti'];

      // Usa i valori ottenuti per calcolare i totali
      totDE += totaleCostiDirettiEconomici;
      totDnE += totaleCostiDirettiNonEconomici;
      totIndiretti += totaleCostiIndiretti;
      totSaldo += saldo;
    }
    double percIndirettiAttEco = 0.0;
    double percIndirettiAttNonEco = 0.0;
    DocumentSnapshot documentSnapshot = await appState.categorie.doc('riepilogoCat').get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      percIndirettiAttEco = data['percIndirettiAttEco'] ?? 0.0;
      percIndirettiAttNonEco = data['percIndirettiAttNonEco'] ?? 0.0;
    }
    print('percIndirettiAttEco: $percIndirettiAttEco');
    print('percIndirettiAttNonEco: $percIndirettiAttNonEco');

    totInE = totIndiretti * percIndirettiAttEco / 100;
    totInnE = totIndiretti * percIndirettiAttNonEco / 100;

    print('totInE $totInE  + totInnE $totInnE: ${totInE + totInnE} == totIndiretti: $totIndiretti');
    final json = {
      'Saldo': totSaldo,
      'Totale Costi Diretti A E': totDE,
      'Totale Costi Diretti A nE': totDnE,
      'Totale Costi Indiretti A E': totInE,
      'Totale Costi Indiretti A nE': totInnE,
    };
    d.update(json);
    totaleCostiDirettiAE = totDE;
    totaleCostiDirettiAnE = totDnE;
    totaleCostiIndirettiAE = totInE;
    totaleCostiIndirettiAnE = totInnE;
    saldo = totSaldo;
  }

  Future<void> valuatePerc() async {
    final appState = Provider.of<AppState>(context, listen: false);
    num percCIAE = 0;
    num percCIAnE = 0;
    num totCIAE = 0;
    num totCIAnE = 0;
    CollectionReference c = appState.categorie;
    totCIAE = 0;
    totCIAnE = 0;
    await appState.categorie.doc('riepilogoCat').get().then(
            (doc) {
          if (doc.exists) {
            totCIAE = num.parse(doc.get('totCostiIndirettiAttEco').toString());
            totCIAnE = num.parse(doc.get('totCostiIndirettiAttNonEco').toString());
          }
        });
    c.get().then(
            (snapshot) => snapshot.docs.forEach(
              (cat) {
            if (cat.id != 'riepilogoCat' && cat.id != 'Valore della Produzione') {
              var sTotCIAE = cat.get('Totale Costi Indiretti A E').toString();
              var sTotCIAnE = cat.get('Totale Costi Indiretti A nE').toString();
              percCIAE = 0;
              percCIAnE = 0;
              percCIAE = 100 * (num.parse(sTotCIAE) / totCIAE);
              percCIAnE = 100 * (num.parse(sTotCIAnE) / totCIAnE);
              final json = {
                'Percentuale CI A E': percCIAE.toStringAsFixed(2),
                'Percentuale CI A nE': percCIAnE.toStringAsFixed(2)
              };
              c.doc(cat.id).update(json);
            }
          },
        ));
  }
}