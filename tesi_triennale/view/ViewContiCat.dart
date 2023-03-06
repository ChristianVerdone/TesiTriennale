import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import '../ModifyData.dart';
import '../model/Conto.dart';
import '../utils.dart';

class ViewContiCatPage extends StatelessWidget{

  List<Conto> contiM = [];
  String idCat;
  List<String> lines = [];
  ViewContiCatPage({super.key, required this.idCat});

  final ScrollController controller1 = ScrollController();
  final ScrollController controller2 = ScrollController();
  List<String> attribute = [ 'CodiceConto', 'DescrizioneConto', 'DataOperazione', 'COD', 'DescrizioneOperazione', 'NumeroDocumento',
    'DataDocumento', 'NumeroFattura', 'Importo', 'Saldo', 'Contropartita', 'CostiDiretti', 'CostiIndiretti', 'AttivitaEconomiche',
    'AttivitaNonEconomiche', 'CodiceProgetto'];
  List<Map<String, dynamic>> csvData = [];
  List<dynamic> conti = [];
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
    await findConti(idCat);
    for (var idC in conti) {
      DocumentReference s = idC as DocumentReference;
     await FirebaseFirestore.instance.collection('conti/${s.id}/lineeConto').get().then(
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
    contiM = convertMapToObject(csvData);
    await valuateTot();
    await valuatePerc();
  }

  Future findConti(String idcat) async {
    await FirebaseFirestore.instance.collection('categorie').get().then(
            (snapshot) => snapshot.docs.forEach(
                (cat) {
              if(cat.id == idcat){
                conti = cat.get('Conti') as List<dynamic>;
              }
            }
        )
    );
  }

  Future<void> valuateTot() async {
    num totInnE = 0;
    num totInE = 0;
    num totDnE = 0;
    num totDE = 0;
    for(var linea in contiM){
      if(linea.costiIndiretti){
        if(linea.attivitaNonEconomiche) {
          totInnE = totInnE + num.parse(linea.importo);
        }
        if(linea.attivitaEconomiche){
          totInE = totInE + num.parse(linea.importo);
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
    DocumentReference d = FirebaseFirestore.instance.collection('categorie').doc(idCat);
    d.get().then(
            (cat) {
                final json = {
                  'Conti' : cat.get('Conti'),
                  'Totale Costi Diretti A E' : totDE,
                  'Totale Costi Diretti A nE' : totDnE,
                  'Totale Costi Indiretti A E' : totInE,
                  'Totale Costi Indiretti A nE' : totInnE,
                  'Percentuale CI A E' : cat.get('Percentuale CI A E'),
                  'Percentuale CI A nE' : cat.get('Percentuale CI A nE')
                };
                d.set(json);
            }
    );
  }

  Future<void> valuatePerc() async {
    num percCIAE = 0;
    num percCIAnE = 0;
    num totCIAE = 0;
    num totCIAnE = 0;
    await FirebaseFirestore.instance.collection('categorie').get().then(
            (snapshot) => snapshot.docs.forEach(
                    (cat) {
                      totCIAE = totCIAE + num.parse(cat.get('Totale Costi Indiretti A E').toString());
                      totCIAnE = totCIAnE + num.parse(cat.get('Totale Costi Indiretti A nE').toString());
                    }
            )
    );
    CollectionReference c =  FirebaseFirestore.instance.collection('categorie');
        c.get().then(
            (snapshot) => snapshot.docs.forEach(
                (cat) {
                  var sTotCIAE = cat.get('Totale Costi Indiretti A E').toString();
                  var sTotCIAnE = cat.get('Totale Costi Indiretti A nE').toString();
              percCIAE = 0;
              percCIAnE = 0;
              percCIAE = (num.parse(sTotCIAE) / totCIAE) * 100;
              percCIAnE  = (num.parse(sTotCIAnE) / totCIAnE) * 100;
              var sTotCDAE = cat.get('Totale Costi Diretti A E').toString();
              var sTotCDAnE = cat.get('Totale Costi Diretti A nE').toString();
              final json = {
                'Conti' : cat.get('Conti'),
                'Totale Costi Diretti A E' : sTotCDAE,
                'Totale Costi Diretti A nE' : sTotCDAnE,
                'Totale Costi Indiretti A E' : sTotCIAE,
                'Totale Costi Indiretti A nE' : sTotCIAnE,
                'Percentuale CI A E' : percCIAE.toString(),
                'Percentuale CI A nE' : percCIAnE.toString()
              };
              c.doc(cat.id).set(json);
            }
        )
    );
  }
}