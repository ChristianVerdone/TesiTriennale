import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'scrollable_widget.dart';
import 'show_text_dialog.dart';
import 'conto.dart';
import 'utils.dart';

class ModifyData extends StatefulWidget {
  final List<String> lines;
  final List<Map<String, dynamic>> csvData;
  final String codiceConto;

  const ModifyData({
    super.key,
    required this.csvData,
    required this.lines,
    required this.codiceConto,
  });
  @override
  State<ModifyData> createState() => _ModifyDataState();
}

class _ModifyDataState extends State<ModifyData> {
  List<Conto> conti = [];
  List<String> projects = [];
  final _controller = ScrollController();
  final columns = [
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
    conti = convertMapToObject(widget.csvData);
    getProjects().then((projectList) {
      setState(() {
        projects = projectList;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness:
        Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      centerTitle: true,
      title:  Text(widget.codiceConto,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20.0,
        )),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Applica'),
          onPressed: () async {
            String linea;
            for (int i = 0; i < widget.lines.length; i++) {
              linea = widget.lines[i];
              String idConto = linea.substring(0, 8);
              var conto = conti[i];
              if (kDebugMode) {
                print(conto.descrizioneConto);
              }
              final json = {
                'Codice Conto': widget.codiceConto,
                'Descrizione conto': conto.descrizioneConto,
                'Data operazione': conto.dataOperazione,
                'Descrizione operazione': conto.descrizioneOperazione,
                'Numero documento': conto.numeroDocumento,
                'Data documento': conto.dataDocumento,
                'Importo': conto.importo,
                'Saldo': conto.saldo,
                'Contropartita': conto.contropartita,
                'Costi Diretti': conto.costiDiretti,
                'Costi Indiretti': conto.costiIndiretti,
                'Attività economiche': conto.attivitaEconomiche,
                'Attività non economiche': conto.attivitaNonEconomiche,
                'Codice progetto': conto.codiceProgetto
              };
              await FirebaseFirestore.instance.collection('conti').doc(idConto).collection('lineeConto').doc(linea).set(json);
            }
            Navigator.pop(context, 'refresh');
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
    body: ScrollableWidget(controller: _controller,child: buildDataTable()),
  );

  Widget buildDataTable() {
    return DataTable(
      columns: getColumns(columns),
      rows: getRows(conti),
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

  List<DataRow> getRows(List<Conto> conti) => conti.map((Conto conto) {
    final cells = [
      conto.dataOperazione,
      conto.descrizioneOperazione,
      conto.numeroDocumento,
      conto.dataDocumento,
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
        switch (index) {
          case 6:
            return DataCell(Center(
              child: Tooltip(
                message: 'Costi diretti',
                child: Checkbox(
                  key: GlobalKey(),
                  value: conto.costiDiretti,
                  onChanged: (bool? value) {
                    if (conto.costiDiretti == true) {
                      editCostiDiretti(conto, value);
                    }
                    if (conto.costiIndiretti == true && conto.costiDiretti == false) {
                      editCostiIndiretti(conto, false);
                      editCostiDiretti(conto, value);
                    }
                    if (conto.costiDiretti == false && conto.costiIndiretti == false) {
                      editCostiDiretti(conto, value);
                    }
                  },
                ),
              ),
            ));
          case 7:
            return DataCell(Center(
              child: Tooltip(
                message: 'Costi indiretti',
                child: Checkbox(
                  key: GlobalKey(),
                  value: conto.costiIndiretti,
                  onChanged: (bool? value) {
                    if (conto.costiIndiretti == true) {
                      editCostiIndiretti(conto, value);
                    }
                    if (conto.costiDiretti == true) {
                      editCostiDiretti(conto, false);
                      editCostiIndiretti(conto, value);
                    } else {
                      editCostiIndiretti(conto, value);
                    }
                  },
                )),
            ));
          case 8:
            return DataCell(Center(
              child: Tooltip(
                message: 'Attività economiche',
                child: Checkbox(
                  key: GlobalKey(),
                  value: conto.attivitaEconomiche,
                  onChanged: (bool? value) {
                    if (conto.attivitaEconomiche == true) {
                      editAttivitaEconomiche(conto, value);
                    }
                    if (conto.attivitaNonEconomiche == true) {
                      editAttivitaNonEconomiche(conto, false);
                      editAttivitaEconomiche(conto, value);
                    } else {
                      editAttivitaEconomiche(conto, value);
                    }
                  },
                )),
            ));
          case 9:
            return DataCell(Center(
              child: Tooltip(
                message: 'Attività non economiche',
                child: Checkbox(
                  key: GlobalKey(),
                  value: conto.attivitaNonEconomiche,
                  onChanged: (bool? value) {
                    if (conto.attivitaNonEconomiche == true) {
                      editAttivitaNonEconomiche(conto, value);
                    }
                    if (conto.attivitaEconomiche == true) {
                      editAttivitaEconomiche(conto, false);
                      editAttivitaNonEconomiche(conto, value);
                    } else {
                      editAttivitaNonEconomiche(conto, value);
                    }
                  },
                )),
            ));
          case 10:
            final showEditIcon = index == 10;
            return DataCell(
              Tooltip(
                message: 'Codice progetto',
                child: Text('$cell'),
              ),
              showEditIcon: showEditIcon, onTap: () {
                editCodiceProgetto2(conto);
              }
            );
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
    return testo;
  }

  Future editCostiDiretti(Conto editConto, bool? value) async {
    setState(() => conti = conti.map((conto) {
      var isEditedConto = conto == editConto;
      return isEditedConto ? conto.copy(costiDiretti: value) : conto;
    }).toList());
  }

  Future editCostiIndiretti(Conto editConto, bool? value) async {
    setState(() => conti = conti.map((conto) {
      var isEditedConto = conto == editConto;
      return isEditedConto ? conto.copy(costiIndiretti: value) : conto;
    }).toList());
  }

  Future editAttivitaEconomiche(Conto editConto, bool? value) async {
    setState(() => conti = conti.map((conto) {
      var isEditedConto = conto == editConto;
      return isEditedConto ? conto.copy(attivitaEconomiche: value) : conto;
    }).toList());
  }

  Future editAttivitaNonEconomiche(Conto editConto, bool? value) async {
    setState(() => conti = conti.map((conto) {
      var isEditedConto = conto == editConto;
      return isEditedConto ? conto.copy(attivitaNonEconomiche: value) : conto;
    }).toList());
  }

  Future editCodiceProgetto(Conto editConto) async {
    final codiceProgetto = await showTextDialog(
      context,
      title: 'Modifica nome progetto',
      value: editConto.codiceProgetto,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;
      return isEditedConto ? conto.copy(codiceProgetto: codiceProgetto) : conto;
    }).toList());
  }

  Future<List<String>> getProjects() async {
    final projectsRef = FirebaseFirestore.instance.collection('progetti');
    final snapshot = await projectsRef.get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future editCodiceProgetto2(Conto editConto) async {
    String? selectedProject = 'DefaultProject';
    selectedProject = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Modifica nome progetto'),
              content: DropdownButton<String>(
                value: selectedProject ?? editConto.codiceProgetto,
                isExpanded: true,
                items: projects.map((String project) {
                  return DropdownMenuItem<String>(
                    value: project,
                    child: Text(project),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedProject = newValue;
                  });
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(selectedProject);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedProject != null && selectedProject != 'DefaultProject') {
      setState(() => conti = conti.map((conto) {
        final isEditedConto = conto == editConto;
        return isEditedConto ? conto.copy(codiceProgetto: selectedProject): conto;
      }).toList());
    }
  }
}