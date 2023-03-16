import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../readData/GetProgetto.dart';
import 'insertProgetto.dart';

class VisualizzaProg extends StatefulWidget { //seconda page di caricamento di dati dal database
  const VisualizzaProg({super.key});
  @override
  State<VisualizzaProg> createState() => _VisualizzaProgState();
}

class _VisualizzaProgState extends State<VisualizzaProg> {


  @override
  void initState() {
    super.initState();
  }

  String refresh = '';
  void reload(){
    setState(() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const VisualizzaProg(),
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  num totProgettiE = 0;
  num totProgettinE = 0;
  List<String> progetti = [];

  @override
  Widget build(BuildContext context) {
    valuatetot();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Progetti'),
          actions: <Widget>[
            ElevatedButton(
                onPressed: () async {
                  String refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => insertProgetto()));
                  if(refresh == 'refresh'){
                    reload();
                  }
                },
                child: const Icon(Icons.add))
          ]
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: FutureBuilder(
                    future: getProgetti(),
                    builder: (context, snapshot){
                      return ListView.builder(
                          itemCount: progetti.length,
                          itemBuilder: (context, index){
                            return ListTile(
                              title: GetProgetto(idProg: progetti[index]),
                            );
                          });
                    })
            )
          ],
        ),
      ),
    );
  }

  Future getProgetti() async{
    num perc = 0;
    await FirebaseFirestore.instance.collection('progetti').get().then(
            (snapshot) => snapshot.docs.forEach(
                (progetto) {
              if(!(progetti.contains(progetto.reference.id))){
                progetti.add(progetto.reference.id);
              }
              if(progetto.get('isEconomico')){
                perc = (num.parse(progetto.get('Valore').toString()) / totProgettiE) * 100;
              }
              else{
                perc = (num.parse(progetto.get('Valore').toString()) / totProgettinE) * 100;
              }
              final json = {
                'Anno' : progetto.get('Anno'),
                'Valore' : progetto.get('Valore'),
                'Costi Diretti' : progetto.get('Costi Diretti'),
                'Costi Indiretti' : progetto.get('Costi Indiretti'),
                'isEconomico' : progetto.get('isEconomico'),
                'Percentuale' : perc.toString()
              };
              progetto.reference.set(json);
              perc = 0;
            }
        )
    );
  }

  Future<void> valuatetot() async {
    await FirebaseFirestore.instance.collection('progetti').get().then(
            (snap) => snap.docs.forEach(
                (progetto) {
                  if(progetto.get('isEconomico')){
                    totProgettiE = totProgettiE + num.parse(progetto.get('Valore').toString());
                  }
                  else{
                    totProgettinE = totProgettinE + num.parse(progetto.get('Valore').toString());
                  }
            }
        )
    );
  }
}