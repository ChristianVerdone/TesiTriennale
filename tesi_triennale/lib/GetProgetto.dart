import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Progetto.dart';
import 'VisualizzaProgetto.dart';

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
                    p = Progetto.prog(nomeProgetto: idProg, anno: value.get('Anno'), valore: value.get('Valore'),
                        costiDiretti: value.get('Costi Diretti'), costiIndiretti: value.get('Costi Indiretti'),
                        isEconomico: value.get('isEconomico'), perc: value.get('Percentuale'), contributo: value.get('Contributo Competenza'));
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