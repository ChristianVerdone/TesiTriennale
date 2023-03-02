import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/Progetto.dart';
import '../view/VisualizzaProgetto.dart';

class GetProgetto extends StatelessWidget{

  String idProg;
  late Progetto p;
  GetProgetto({super.key, required this.idProg});

  @override
  Widget build(BuildContext context) {
    CollectionReference progettiRef = FirebaseFirestore.instance.collection('progetti');
    return FutureBuilder<DocumentSnapshot>(
        future: progettiRef.doc(idProg).get(),
        builder: ((context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            return TextButton(
                onPressed: () async {
                  await progettiRef.doc(idProg).get().then((value) {
                    print(value.id);
                    p = Progetto.prog(nomeProgetto: idProg, anno: value.get('Anno'), valore: value.get('Valore'),
                        costiDiretti: value.get('Costi Diretti'), costiIndiretti: value.get('Costi Indiretti'));
                  });
                  Navigator.push(context, MaterialPageRoute(builder: (context) => VisualizzaProgetto(p: p)));
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