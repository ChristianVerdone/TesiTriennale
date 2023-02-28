import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../view/VisualizzaProgetto.dart';

class GetProgetto extends StatelessWidget{

  String idProg;

  GetProgetto({super.key, required this.idProg});

  @override
  Widget build(BuildContext context) {
    CollectionReference lineeConto = FirebaseFirestore.instance.collection('progetti');
    return FutureBuilder<DocumentSnapshot>(
        future: lineeConto.doc(idProg).get(),
        builder: ((context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            return TextButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => VisualizzaProgetto(idProgetto: idProg)));
                },
                child: Text(idProg)
            );
          }
          return const Center(
            child: Text('loading...'),
          );
        })
    );
  }
}