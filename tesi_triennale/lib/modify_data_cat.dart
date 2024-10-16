import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'scrollable_widget.dart';
import 'show_text_dialog.dart';
import 'conto.dart';
import 'utils.dart';

class ModifyDataCat extends StatefulWidget {
  final List<Map<String, dynamic>> csvData;
  List<Map<String, dynamic>> lines;
  String idCat;

  ModifyDataCat({super.key, required this.csvData, required List<String> lines, required this.idCat})
      : lines = lines.map((line) => {'linea': line, 'isModified': false}).toList();

  @override
  State<ModifyDataCat> createState() => _ModifyDataCatState();
}

class _ModifyDataCatState extends State<ModifyDataCat> {
  List<Conto> conti = [];
  List<String> projects = [];
  LinkedHashMap<String, double> projectAmounts = LinkedHashMap<String, double>();

  final ScrollController _controller = ScrollController();
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';


  @override
  void initState() {
    super.initState();
    conti = convertMapToObject2(widget.csvData);
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
      title: const Text('Modifica',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
          )),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Applica'),
          onPressed: () async {
            if(widget.idCat == 'Personale'){
              for (int i = 0; i < widget.lines.length; i++) {
                if (widget.lines[i]['isModified'] == false) {
                  continue;
                }
                else {
                  String linea = widget.lines[i]['linea'];
                  String idConto = linea.substring(0, 8);
                  var conto = conti[i];
                  var projectAmounts = conto.projectAmounts;
                  final json = {
                    'Codice Conto': conto.codiceConto,
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
                    'Codice progetto': conto.codiceProgetto,
                    'Project Amounts': projectAmounts
                  };
                  await FirebaseFirestore.instance.collection('conti').doc(
                      idConto).collection('lineeConto').doc(linea).set(json,
                      SetOptions(merge: true));
                }
              }
            }
            else {
              String linea;
              for (int i = 0; i < widget.lines.length; i++) {
                if (widget.lines[i]['isModified'] == false) {
                  continue;
                }
                else {
                  linea = widget.lines[i]['linea'];
                  String idConto = linea.substring(0, 8);
                  final json = {
                    'Codice Conto': conti[i].codiceConto,
                    'Descrizione conto': conti[i].descrizioneConto,
                    'Data operazione': conti[i].dataOperazione,
                    'Descrizione operazione': conti[i].descrizioneOperazione,
                    'Numero documento': conti[i].numeroDocumento,
                    'Data documento': conti[i].dataDocumento,
                    'Importo': conti[i].importo,
                    'Saldo': conti[i].saldo,
                    'Contropartita': conti[i].contropartita,
                    'Costi Diretti': conti[i].costiDiretti,
                    'Costi Indiretti': conti[i].costiIndiretti,
                    'Attività economiche': conti[i].attivitaEconomiche,
                    'Attività non economiche': conti[i].attivitaNonEconomiche,
                    'Codice progetto': conti[i].codiceProgetto
                  };
                  await FirebaseFirestore.instance.collection('conti').doc(
                      idConto).collection('lineeConto').doc(linea).set(json,
                      SetOptions(merge: true));
                }
              }
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
    body:  Column(
      children: [
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
          child: ScrollableWidget(
            controller: _controller,
            child: buildDataTable(),
          ),
        ),
      ],
    ),
  );

  Widget buildDataTable() {
    final filteredConti = filterConti(conti, _searchQuery);
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

  List<DataRow> getRows(List<Conto> conti) => conti.map((Conto conto) {
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
        switch (index) {
          case 9:
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
                    if (conto.costiIndiretti == true &&
                        conto.costiDiretti == false) {
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
          case 10:
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
          case 11:
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
          case 12:
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
          case 13:
            final showEditIcon = index == 13;
            return DataCell(
                Tooltip(
                  message: 'Codice progetto',
                  child: Text('$cell'),
                ),
                showEditIcon: showEditIcon, onTap: () {
              editCodiceProgetto2(conto);
            });
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
    if (i == 8) return columns[i];
    return testo;
  }

  Future editCostiDiretti(Conto editConto, bool? value) async {
    setState(() => conti = conti.map((conto) {
      var isEditedConto = conto == editConto;
      if(isEditedConto == true) {
        widget.lines[conti.indexOf(conto)]['isModified'] = true;
      }
      return isEditedConto ? conto.copy(costiDiretti: value) : conto;
    }).toList());
  }

  Future editCostiIndiretti(Conto editConto, bool? value) async {
    setState(() => conti = conti.map((conto) {
      var isEditedConto = conto == editConto;
      if(isEditedConto == true) {
        widget.lines[conti.indexOf(conto)]['isModified'] = true;
      }
      return isEditedConto ? conto.copy(costiIndiretti: value) : conto;
    }).toList());
  }

  Future editAttivitaEconomiche(Conto editConto, bool? value) async {
    setState(() => conti = conti.map((conto) {
      var isEditedConto = conto == editConto;
      if(isEditedConto == true) {
        widget.lines[conti.indexOf(conto)]['isModified'] = true;
      }
      return isEditedConto ? conto.copy(attivitaEconomiche: value) : conto;
    }).toList());
  }

  Future editAttivitaNonEconomiche(Conto editConto, bool? value) async {
    setState(() => conti = conti.map((conto) {
      var isEditedConto = conto == editConto;
      if(isEditedConto == true) {
        widget.lines[conti.indexOf(conto)]['isModified'] = true;
      }
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
      if(isEditedConto == true) {
        widget.lines[conti.indexOf(conto)]['isModified'] = true;
      }
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
    double totalAmount = double.parse(editConto.importo);
    double total = totalAmount;
    var filteredProjects = projects.where((element) => element != 'DefaultProject').toList();
    if(widget.idCat == 'Personale'){
      projectAmounts = editConto.projectAmounts!;
      if (projectAmounts.isNotEmpty) {
        total = totalAmount - projectAmounts.values.reduce((a, b) => a + b);
      }
      projectAmounts = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Modifica nome progetto'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text('Importo residuo da assegnare: $total'), ...filteredProjects.map((String project) {
                        return Row(
                          children: [
                            Checkbox(
                              value: projectAmounts.containsKey(project),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    projectAmounts[project] = 0;
                                  } else {
                                    projectAmounts.remove(project);
                                  }
                                });
                              },
                            ),
                            Text(project),
                            const SizedBox(width: 10),
                            if (projectAmounts.containsKey(project))
                              Expanded(
                                child: TextFormField(
                                  initialValue: projectAmounts[project].toString(),
                                  onFieldSubmitted: (value) {
                                    double amount = double.tryParse(value) ?? 0;
                                    if (amount > 0 && amount <= totalAmount) {
                                      double total2 = totalAmount - amount - projectAmounts.values.reduce((a, b) => a + b);
                                      setState(() {
                                        projectAmounts[project] = amount;
                                        total = total2;
                                      });
                                    }
                                    if(amount == 0){
                                      setState(() {
                                        projectAmounts.remove(project);
                                      });
                                      double total2 = totalAmount - projectAmounts.values.reduce((a, b) => a + b);
                                      setState(() {
                                        total = total2;
                                      });
                                    }
                                  },
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop(projectAmounts);
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }
    else {
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
    }

    if (projectAmounts.isNotEmpty) {
      setState(() {
        conti = conti.map((conto) {
          final isEditedConto = conto == editConto;
          if(isEditedConto == true) {
            widget.lines[conti.indexOf(conto)]['isModified'] = true;
          }
          return isEditedConto ? conto.copy(
            projectAmounts: projectAmounts,
          ) : conto;
        }).toList();
      });
    }

    if (selectedProject != null && selectedProject != 'DefaultProject') {
      setState(() => conti = conti.map((conto) {
        final isEditedConto = conto == editConto;
        if(isEditedConto == true) {
          widget.lines[conti.indexOf(conto)]['isModified'] = true;
        }
        return isEditedConto ? conto.copy(codiceProgetto: selectedProject) : conto;
      }).toList());
    }
  }
}