import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Widget/ScrollableWidget.dart';
import '../utils.dart';
import '../view/VisualizzaTabConto.dart';

class GetConto extends StatelessWidget{

  String idConto;
  List<ShortConto> collection = [];

  GetConto({required this.idConto});

  @override
  Widget build(BuildContext context) {
    getCodDesc(idConto);
    CollectionReference lineeConto = FirebaseFirestore.instance.collection('conti');
    return FutureBuilder<DocumentSnapshot>(
        future: lineeConto.doc(idConto).get(),
        builder: ((context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            return TextButton(
                onPressed: (){
                  for(ShortConto c in collection)
                    if(c.codiceConto == idConto)
                      Navigator.push(context, MaterialPageRoute(builder: (context) => VisualizzaConto(idConto: c.codiceConto, descrizioneConto: c.descrizioneConto)));
                },
                child: Text(idConto)
            );
          }
          return const Center(
            child: Text('loading...'),
          );
        })
    );
  }

  Future getCodDesc(String idConto) async{
    final CollectionReference lineeConto = FirebaseFirestore.instance.collection('conti');
    final QuerySnapshot querySnapshot = await lineeConto.get();

    querySnapshot.docs.forEach((lineaConto) async {
      String subConto = idConto + 'line_000';
      final CollectionReference subCollectionRef = lineaConto.reference.collection('lineeConto');
      final QuerySnapshot subQuerySnapshot = await subCollectionRef.get();

      subQuerySnapshot.docs.forEach((subDoc){
        if(subConto == subDoc.id){
          collection.add(ShortConto(codiceConto: subDoc.get('Codice Conto'), descrizioneConto: subDoc.get('Descrizione conto')));
        }
      });
    });

  }

  Widget buildDataTable() {
    final columns = [
      'Codice conto',
      'Descrizione conto'
    ];

    return DataTable(
      columns: getColumns(columns),
      rows: getRows(collection),
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

  List<DataRow> getRows(List<ShortConto> collection) => collection.map((ShortConto conto) {
    final cells = [
      conto.codiceConto,
      conto.descrizioneConto,
    ];

    return DataRow(
      cells: Utils.modelBuilder(cells, (index, cell) {
        return DataCell(
          Text('$cell'),
        );
      }),
    );
  }).toList();

}

class ShortConto{
  final String codiceConto;
  final String descrizioneConto;

  const ShortConto({
    required this.codiceConto,
    required this.descrizioneConto,
  });
}