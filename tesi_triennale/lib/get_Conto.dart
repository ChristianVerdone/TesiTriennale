import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Visualizza_Tab_Conto.dart';

class GetConto extends StatelessWidget{

  String idConto;
  String descrizione = '';
  
  GetConto({super.key, required this.idConto});

  @override
  Widget build(BuildContext context) {
    CollectionReference lineeConto = FirebaseFirestore.instance.collection('conti');
    lineeConto.doc(idConto).get().then((value) => descrizione = value.get('Descrizione conto'));
    return FutureBuilder<DocumentSnapshot>(
        future: lineeConto.doc(idConto).get(),
        builder: ((context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            return TextButton(
                onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => VisualizzaConto(idConto: idConto, descrizioneConto: descrizione)));
                },
                child: Text('$idConto    -    $descrizione')
            );
          }
          return const Center(
            child: Text('loading...'),
          );
        })
    );
  }

  /*
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

   */
}
