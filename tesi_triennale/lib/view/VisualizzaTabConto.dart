import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

class VisualizzaConto extends StatelessWidget{

  String idConto;
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
              print(linea.reference);
              csvData.add(linea.data());
            }
        )
    );
  }
}