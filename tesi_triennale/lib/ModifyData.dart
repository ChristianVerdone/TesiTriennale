import 'package:cloud_firestore/cloud_firestore.dart';
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
  final Stream<QuerySnapshot> snap = FirebaseFirestore.instance.collection('conti/8.01.031/lineeConto').snapshots();
  @override
  void initState() {
    super.initState();
    conti = convertMapToObject(widget.csvData);
    print(conti[0].numeroDocumento);
    print(conti[1].numeroDocumento);
    print(conti[2].numeroDocumento);
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
        final showEditIcon = index  > 0 && index < 16;
        return DataCell(
            Text('$cell'),
            showEditIcon: showEditIcon,
            onTap: (){
              switch(index){
                case 1:
                  editDescrizioneConto(conto);
                  break;
                case 2:
                  editDataOperazione(conto);
                  break;
                case 3:
                  editCOD(conto);
                  break;
                case 4:
                  editDescrizioneOperazione(conto);
                  break;
                case 5:
                  editNumeroDocumento(conto);
                  break;
                case 6:
                  editDataDocumento(conto);
                  break;
                case 7:
                  editNumeroFattura(conto);
                  break;
                case 8:
                  editImporto(conto);
                  break;
                case 9:
                  editSaldo(conto);
                  break;
                case 10:
                  editContropartita(conto);
                  break;
                case 11:
                  editCostiDiretti(conto);
                  break;
                case 12:
                  editCostiIndiretti(conto);
                  break;
                case 13:
                  editAttivitaEconomiche(conto);
                  break;
                case 14:
                  editAttivitaNonEconomiche(conto);
                  break;
                case 15:
                  editCodiceProgetto(conto);
                  break;
              }
            }
        );
      }),
    );
  }
  ).toList();


  Future editDescrizioneConto(Conto editConto) async {
    final descrizioneConto = await showTextDialog(
      context,
      title: 'Modifica descrizione conto',
      value: editConto.descrizioneConto,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;

      return isEditedConto ? conto.copy(descrizioneConto: descrizioneConto) : conto;
      }).toList());
    }

  Future editDataOperazione(Conto editConto)  async{
    final dataOperazione = await showTextDialog(
        context,
        title: 'Modifica data operazione',
        value: editConto.dataOperazione,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;
      
      return isEditedConto ? conto.copy(dataOperazione: dataOperazione) : conto;
    }).toList());
  }

  Future editCOD(Conto editConto)  async{
    final COD = await showTextDialog(
        context,
        title: 'Modifica COD',
        value: editConto.COD,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;
      
      return isEditedConto ? conto.copy(COD: COD) : conto;
    }).toList());
  }

  Future editDescrizioneOperazione(Conto editConto)  async{
    final descrizioneOperazione = await showTextDialog(
        context,
        title: 'Modifica descrizione operazione',
        value: editConto.descrizioneOperazione,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;
      
      return isEditedConto ? conto.copy(descrizioneOperazione: descrizioneOperazione) : conto;
    }).toList());
  }

  Future editNumeroDocumento(Conto editConto)  async{
    final numeroDocumento = await showTextDialog(
        context,
        title: 'Modifica numero documento',
        value: editConto.numeroDocumento,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;
      
      return isEditedConto ? conto.copy(numeroDocumento: numeroDocumento) : conto;
    }).toList());
  }

  Future editDataDocumento(Conto editConto)  async{
    final dataDocumento = await showTextDialog(
        context,
        title: 'Modifica data documento',
        value: editConto.dataDocumento,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;
      
      return isEditedConto ? conto.copy(dataDocumento: dataDocumento) : conto;
    }).toList());
  }

  Future editNumeroFattura(Conto editConto)  async{
    final numeroFattura = await showTextDialog(
        context,
        title: 'Modifica numero fattura',
        value: editConto.numeroFattura,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;
      
      return isEditedConto ? conto.copy(numeroFattura: numeroFattura) : conto;
    }).toList());
  }

  Future editImporto(Conto editConto)  async{
    final importo = await showTextDialog(
        context,
        title: 'Modifica importo',
        value: editConto.importo,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;

      return isEditedConto ? conto.copy(importo: importo) : conto;
    }).toList());
  }

  Future editSaldo(Conto editConto)  async{
    final saldo = await showTextDialog(
        context,
        title: 'Modifica saldo',
        value: editConto.saldo,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;

      return isEditedConto ? conto.copy(saldo: saldo) : conto;
    }).toList());
  }

  Future editContropartita(Conto editConto) async{
    final contropartita = await showTextDialog(
      context,
      title: 'Modifica contropartita',
      value: editConto.contropartita,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;

      return isEditedConto ? conto.copy(contropartita: contropartita) : conto;
    }).toList());
  }

  Future editCostiDiretti(Conto editConto)  async{
    final costiDiretti = await showTextDialog(
        context,
        title: 'Modifica costi diretti',
        value: editConto.costiDiretti,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;

      return isEditedConto ? conto.copy(costiDiretti: costiDiretti) : conto;
    }).toList());
  }

  Future editCostiIndiretti(Conto editConto)  async{
    final costiIndiretti = await showTextDialog(
        context,
        title: 'Modifica costi indiretti',
        value: editConto.costiIndiretti,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;

      return isEditedConto ? conto.copy(costiIndiretti: costiIndiretti) : conto;
    }).toList());
  }

  Future editAttivitaEconomiche(Conto editConto)  async{
    final attivitaEconomiche = await showTextDialog(
        context,
        title: 'Modifica attività economiche',
        value: editConto.attivitaEconomiche,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;

      return isEditedConto ? conto.copy(attivitaEconomiche: attivitaEconomiche) : conto;
    }).toList());
  }

  Future editAttivitaNonEconomiche(Conto editConto)  async{
    final attivitaNonEconomiche = await showTextDialog(
        context,
        title: 'Modifica attività non economiche',
        value: editConto.attivitaNonEconomiche,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;

      return isEditedConto ? conto.copy(attivitaNonEconomiche: attivitaNonEconomiche) : conto;
    }).toList());
  }

  Future editCodiceProgetto(Conto editConto)  async{
    final codiceProgetto = await showTextDialog(
        context,
        title: 'Modifica codice progetto',
        value: editConto.codiceProgetto,
    );

    setState(() => conti = conti.map((conto) {
      final isEditedConto = conto == editConto;

      return isEditedConto ? conto.copy(codiceProgetto: codiceProgetto) : conto;
    }).toList());
  }
}
