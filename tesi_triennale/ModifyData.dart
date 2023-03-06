import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Widget/ScrollableWidget.dart';
import 'Widget/showTextDialog.dart';
import 'model/Conto.dart';
import 'utils.dart';
import 'view/VisualizzaTabConto.dart';

class ModifyData extends StatefulWidget {
  final List<String> lines;
  final List<Map<String, dynamic>> csvData;

  const ModifyData({super.key, required this.csvData, required this.lines});
  @override
  State<ModifyData> createState() => _ModifyDataState();
}

class _ModifyDataState extends State<ModifyData> {
  List<Conto> conti = [];

  @override
  void initState() {
    super.initState();
    conti = convertMapToObject(widget.csvData);
  }


  @override
  Widget build(BuildContext context) => Scaffold(
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
      title: const Text('Modifica',
          style: TextStyle(
            color: Colors.white,
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

              final json = {
                'Codice Conto': conti[i].codiceConto,
                'Descrizione conto': conti[i].descrizioneConto,
                'Data operazione': conti[i].dataOperazione,
                'COD': conti[i].COD,
                'Descrizione operazione': conti[i].descrizioneOperazione,
                'Numero documento': conti[i].numeroDocumento,
                'Data documento': conti[i].dataDocumento,
                'Numero Fattura': conti[i].numeroFattura,
                'Importo': conti[i].importo,
                'Saldo': conti[i].saldo,
                'Contropartita': conti[i].contropartita,
                'Costi Diretti': conti[i].costiDiretti,
                'Costi Indiretti': conti[i].costiIndiretti,
                'Attività economiche': conti[i].attivitaEconomiche,
                'Attività non economiche': conti[i].attivitaNonEconomiche,
                'Codice progetto': conti[i].codiceProgetto
              };

              await FirebaseFirestore.instance
                  .collection('conti')
                  .doc(idConto)
                  .collection('lineeConto')
                  .doc(linea)
                  .set(json);
            }
            Navigator.pop(context, 'refresh');
          },
        ),
      ],
    ),
    body: ScrollableWidget(child: buildDataTable()),
  );

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
        switch (index) {
          case 8:
            return DataCell(Center(
              child: Checkbox(
                key: GlobalKey(),
                value: conto.costiDiretti,
                onChanged: (bool? value) {
                  if(conto.costiDiretti == true) {
                    editCostiDiretti(conto, value);
                  }
                  if (conto.costiIndiretti == true && conto.costiDiretti == false) {
                    editCostiIndiretti(conto, false);
                    editCostiDiretti(conto, value);
                  }
                  if(conto.costiDiretti == false && conto.costiIndiretti == false) {
                    editCostiDiretti(conto, value);
                  }
                },
              ),
            ));
          case 9:
            return DataCell(Center(
              child: Checkbox(
                key: GlobalKey(),
                value: conto.costiIndiretti,
                onChanged: (bool? value) {
                  if(conto.costiIndiretti == true)
                    editCostiIndiretti(conto, value);
                  if (conto.costiDiretti == true) {
                    editCostiDiretti(conto, false);
                    editCostiIndiretti(conto, value);
                  } else
                    editCostiIndiretti(conto, value);
                },
              ),
            ));
          case 10:
            return DataCell(Center(
              child: Checkbox(
                key: GlobalKey(),
                value: conto.attivitaEconomiche,
                onChanged: (bool? value) {
                  if(conto.attivitaEconomiche == true)
                    editAttivitaEconomiche(conto, value);
                  if (conto.attivitaNonEconomiche == true) {
                    editAttivitaNonEconomiche(conto, false);
                    editAttivitaEconomiche(conto, value);
                  } else
                    editAttivitaEconomiche(conto, value);
                },
              ),
            ));
          case 11:
            return DataCell(Center(
              child: Checkbox(
                key: GlobalKey(),
                value: conto.attivitaNonEconomiche,
                onChanged: (bool? value) {
                  if(conto.attivitaNonEconomiche == true)
                    editAttivitaNonEconomiche(conto, value);
                  if (conto.attivitaEconomiche == true) {
                    editAttivitaEconomiche(conto, false);
                    editAttivitaNonEconomiche(conto, value);
                  } else
                    editAttivitaNonEconomiche(conto, value);
                },
              ),
            ));
          case 12:
            final showEditIcon = index == 12;
            return DataCell(Text('$cell'), showEditIcon: showEditIcon,
                onTap: () {
                  editCodiceProgetto(conto);
                });
        }
        return DataCell(
            Text('$cell')
        );
      }),
    );
  }).toList();


  Future editCostiDiretti(Conto editConto, bool? value)  async{
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

      return isEditedConto
          ? conto.copy(attivitaNonEconomiche: value)
          : conto;
    }).toList());
  }

  Future editCodiceProgetto(Conto editConto) async {
    final codiceProgetto = await showTextDialog(
      context,
      title: 'Modifica codice progetto',
      value: editConto.codiceProgetto,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;

      return isEditedConto
          ? conto.copy(codiceProgetto: codiceProgetto)
          : conto;
    }).toList());
  }
}
