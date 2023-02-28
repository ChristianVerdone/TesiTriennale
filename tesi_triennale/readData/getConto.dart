import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../view/VisualizzaTabConto.dart';

class GetConto extends StatelessWidget{

  String idConto;

  GetConto({required this.idConto});

  @override
  Widget build(BuildContext context) {
    CollectionReference lineeConto = FirebaseFirestore.instance.collection('conti');
    return FutureBuilder<DocumentSnapshot>(
        future: lineeConto.doc(idConto).get(),
        builder: ((context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            return TextButton(
                onPressed: (){

                 Navigator.push(context, MaterialPageRoute(builder: (context) => VisualizzaConto(idConto: this.idConto)));
                },
                child: Text(idConto)
            );
          }
          return Center(
            child: Text('loading...'),
          );
        })
    );
  }
}