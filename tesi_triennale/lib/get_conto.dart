import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'visualizza_tab_conto.dart';

class GetConto extends StatelessWidget{
  String idConto;
  GetConto({super.key, required this.idConto});
  String descrizione = '';

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
}