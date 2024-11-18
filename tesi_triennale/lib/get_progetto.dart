import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'app_state.dart';
import 'progetto.dart';
import 'visualizza_progetto.dart';

class GetProgetto extends StatelessWidget {
  final String idProg;
  late Progetto p;
  GetProgetto({super.key, required this.idProg});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    CollectionReference progettiRef = appState.progetti;
    return FutureBuilder<DocumentSnapshot>(
      future: progettiRef.doc(idProg).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return TextButton(
            onPressed: () async {
              await progettiRef.doc(idProg).get().then(
                (value) {
                  p = Progetto.prog(
                    nomeProgetto: idProg,
                    anno: value.get('Anno'),
                    valore: value.get('Valore'),
                    costiDiretti: value.get('Costi Diretti'),
                    costiIndiretti: value.get('Costi Indiretti'),
                    isEconomico: value.get('isEconomico'),
                    perc: value.get('Percentuale'),
                    contributo: value.get('Contributo Competenza'),
                    references: value.get('CostiDirettiValue'),
                    isA1: (value.data() as Map<String, dynamic>).containsKey('isA1') ? value.get('isA1') : false,
                    isA5: (value.data() as Map<String, dynamic>).containsKey('isA5') ? value.get('isA5') : false,
                  );
                },
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VisualizzaProgetto(p: p),
                ),
              );
            },
            child: Text(idProg),
          );
        }
        return const Center(
          child: Text('loading...'),
        );
      },
    );
  }
}