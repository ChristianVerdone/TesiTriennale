import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

import '../ModifyData.dart';

class VisualizzaConto extends StatelessWidget{

  String idConto;
  List<String> lines = [];
  VisualizzaConto({super.key, required this.idConto});

  final ScrollController controller1 = ScrollController();
  final ScrollController controller2 = ScrollController();
  List<String> attribute = [ 'CodiceConto', 'DescrizioneConto', 'DataOperazione', 'COD', 'DescrizioneOperazione', 'NumeroDocumento',
  'DataDocumento', 'NumeroFattura', 'Importo', 'Saldo', 'Contropartita', 'CostiDiretti', 'CostiIndiretti', 'AttivitaEconomiche',
  'AttivitaNonEconomiche', 'CodiceProgetto'];
  List<Map<String, dynamic>> csvData = [];
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
        title: const Text('Visualizzazione conto',
            style: TextStyle(color: Colors.white,
              fontSize: 20.0, )
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Modifica'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>  ModifyData(csvData: csvData, idConto: idConto, lines: lines)));
            },
          ),
        ],
      ),
      body: FutureBuilder(future: getLines(idConto),
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

  Future getLines(String idConto) async{
    await FirebaseFirestore.instance.collection('conti/'+idConto+'/lineeConto').get().then(
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
  }

  Future getLinesConto(String idConto) async{
    await FirebaseFirestore.instance.collection('conti/'+idConto+'/lineeConto').get().then(
            (snapshot) => snapshot.docs.forEach(
                (linea) {
              //print(linea.reference);
              csvData.add(linea.data());
              
            }
        )
    );
  }
}