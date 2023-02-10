import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetConto extends StatelessWidget{

  String idConto;

  GetConto({required this.idConto});

  @override
  Widget build(BuildContext context) {
    CollectionReference conti = FirebaseFirestore.instance.collection('conti');
    return FutureBuilder<DocumentSnapshot>(
        future: conti.doc(idConto+'/lineeConto').get(),
        builder: ((context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            return Text('lineeConto: ${data['lineeConto']}');
          }
          return Text('loading...');
        })
    );

  }
}