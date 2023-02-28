import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../view/VisualizzaTabConto.dart';

class GetConto extends StatelessWidget{

  String idConto;

  GetConto({super.key, required this.idConto});

  @override
  Widget build(BuildContext context) {
    CollectionReference lineeConto = FirebaseFirestore.instance.collection('conti');
    return FutureBuilder<DocumentSnapshot>(
        future: lineeConto.doc(idConto).get(),
        builder: ((context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            return TextButton(
                onPressed: (){

                 Navigator.push(context, MaterialPageRoute(builder: (context) => VisualizzaConto(idConto: idConto)));
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
}