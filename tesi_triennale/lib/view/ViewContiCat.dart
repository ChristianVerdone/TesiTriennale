import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import '../ModifyData.dart';

class ViewContiCatPage extends StatelessWidget{

  String idCat;
  List<String> lines = [];
  ViewContiCatPage({super.key, required this.idCat});

  final ScrollController controller1 = ScrollController();
  final ScrollController controller2 = ScrollController();
  List<String> attribute = [ 'CodiceConto', 'DescrizioneConto', 'DataOperazione', 'COD', 'DescrizioneOperazione', 'NumeroDocumento',
    'DataDocumento', 'NumeroFattura', 'Importo', 'Saldo', 'Contropartita', 'CostiDiretti', 'CostiIndiretti', 'AttivitaEconomiche',
    'AttivitaNonEconomiche', 'CodiceProgetto'];
  List<Map<String, dynamic>> csvData = [];
  List<String> conti = [];
  @override
  Widget build(BuildContext context) {

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
          title: Text(idCat,
              style: const TextStyle(color: Colors.white,
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
        body: FutureBuilder(future: getLinesConto(),
            builder: (context, snapshot){
              return Scrollbar(
                controller: controller2,
                thumbVisibility: false,
                child: SingleChildScrollView(
                  controller: controller2,
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    controller: controller1,
                    child: DataTable(
                      columns: attribute
                          .map(
                            (item) => DataColumn(
                          label: Text(
                            item.toString(),
                          ),
                        ),
                      )
                          .toList(),
                      rows: csvData
                          .map(
                            (csvrow) => DataRow(
                          cells: csvrow.values
                              .map(
                                (csvItem) => DataCell(
                              Text(
                                csvItem.toString(),
                              ),
                            ),
                          ).toList(),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),
              );
            })
    );
  }

  Future getLinesConto() async {
    findConti(idCat);
    for (String idC in conti) {
     await FirebaseFirestore.instance.collection('conti/$idC/lineeConto').get().then(
              (snapshot) => snapshot.docs.forEach(
                  (linea) {
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
    }
  }

  Future findConti(String idcat) async {
    switch (idcat) {
      case 'Materie Prime':{
        conti = ['8.01.010', '8.11.011'];
      }break;
      case 'Servizi':{
        conti = ['8.01.009', '8.01.031', '8.04.010', '8.09.005', '8.11.013', '8.14.000', '8.14.001', '8.14.004', '8.14.007',
          '8.14.021', '8.14.024', '8.16.000', '8.16.019', '8.17.000', '8.18.000', '8.19.000'];
      }break;
      case 'God beni terzi':{
        conti = [' 8.12.000'];
      }break;
      case 'Ammortamenti':{
        conti = ['8.22.003', '8.22.005', '8.22.009', '8.22.010', '8.22.013', '8.22.015', '8.26.004'];
      }break;
      case 'Oneri diversi':{
        conti = ['8.11.000', '8.14.005', '8.14.010', '8.14.011', '8.15.005', '8.17.006', '8.20.002', '8.20.007', '8.20.010',
          '8.21.000', '8.21.005', '8.21.006', '8.36.001', '8.36.004', '8.37.010', '8.38.003', '8.38.004', '8.38.005',
          '8.38.012', '8.46.005', '8.46.007', '8.46.008', '8.46.009'];
      }break;
    }
  }
}