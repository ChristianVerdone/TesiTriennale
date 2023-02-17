import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tesi_triennale/Widget/ScrollableWidget.dart';
import 'package:tesi_triennale/model/Conto.dart';
import 'package:tesi_triennale/utils.dart';

import 'Widget/showTextDialog.dart';

class ModifyData extends StatefulWidget{
  final String idConto;
  final List<Map<String, dynamic>> csvData;

  ModifyData({super.key, required this.csvData, required this.idConto});
  @override
  State<ModifyData> createState() => _ModifyDataState();
}

class _ModifyDataState extends State<ModifyData>{
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
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
      ),
      centerTitle: true,
      title: const Text('Modifica',
          style: TextStyle(color: Colors.white,
            fontSize: 20.0, )
      ),
    ),
    body: ScrollableWidget(child: buildDataTable()),
  );

  Widget buildDataTable() {

    final columns = [ 'CodiceConto', 'DescrizioneConto', 'DataOperazione', 'COD', 'DescrizioneOperazione', 'NumeroDocumento',
      'DataDocumento', 'NumeroFattura', 'Importo', 'Saldo', 'Contropartita', 'CostiDiretti', 'CostiIndiretti', 'AttivitaEconomiche',
      'AttivitaNonEconomiche', 'CodiceProgetto'];

    return DataTable(
      columns: getColumns(columns),
      rows: getRows(conti),
    );
  }

  List<DataColumn> getColumns(List<String> columns){
    return columns.map(
          (item) => DataColumn(
        label: Text(
          item.toString(),
        ),
      ),
    ).toList();
  }

  List<Conto> convertMapToObject(List<Map<String, dynamic>> csvData) => csvData.map((item) => Conto(
      codiceConto: item['Codice Conto'],
      descrizioneConto: item['Descrizione conto'],
      dataOperazione: item['Data operazione'],
      COD: item['COD'],
      descrizioneOperazione: item['Descrizione operazione'],
      numeroDocumento: item['Numero documento'],
      dataDocumento: item['Data documento'],
      numeroFattura: item['Numero Fattura'],
      importo: item['Importo'],
      saldo: item['Saldo'],
      contropartita: item['Contropartita'],
      costiDiretti: item['Costi Diretti'],
      costiIndiretti: item['Costi Indiretti'],
      attivitaEconomiche: item['Attività economiche'],
      attivitaNonEconomiche: item['Attività non economiche'],
      codiceProgetto: item['Codice progetto'])
  ).toList();

  List<DataRow> getRows(List<Conto> conti) => conti.map((Conto conto){

    final cells = [conto.codiceConto,
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
      conto.codiceProgetto];

    return DataRow(
      cells: Utils.modelBuilder(cells, (index, cell) {
        final showEditIcon = index  == 0 || index == 1;
        return DataCell(
            Text('$cell'),
            showEditIcon: showEditIcon,
            onTap: (){
              switch(index){
                case 0:
                editCodiceConto(conto);
                  break;
                case 1:
                // editLastName(user);
                  break;
              }
            }
        );
      }),
    );
  }).toList();

  Future editCodiceConto(Conto editConto) async {
    final codiceConto = await showTextDialog(
      context,
      title: 'Modifica codice conto',
      value: editConto.codiceConto,
    );

    setState(() { conti = conti.map((conto) {
      final isEditedUser = conto.codiceConto != codiceConto;
      print(codiceConto);
      print(isEditedUser);
      return isEditedUser ? conto.copy(codiceConto: codiceConto) : conto;
    }).toList();
    });
  }
/*
  Future editLastName(User editUser) async {
    final lastName = await showTextDialog(
      context,
      title: 'Modifica cognome',
      value: editUser.lastName,
    );

    setState(() => users = users.map((user) {
      final isEditedUser = user == editUser;

      return isEditedUser ? user.copy(lastName: lastName) : user;
    }).toList());
  }

 */
}
