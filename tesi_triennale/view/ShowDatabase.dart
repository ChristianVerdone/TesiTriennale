import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../readData/getConto.dart';
import 'viewcategorie.dart';

class VisualizzaPage extends StatefulWidget { //seconda page di caricamento di dati dal database
  const VisualizzaPage({super.key});
  @override
  State<VisualizzaPage> createState() => _VisualizzaPageState();
}

class _VisualizzaPageState extends State<VisualizzaPage>{

  @override
  void initState() {
    super.initState();
  }

  List<String> conti = [];

  Future getConti() async{
    await FirebaseFirestore.instance.collection('conti').get().then(
            (snapshot) => snapshot.docs.forEach(
                (conto) {
              if(!(conti.contains(conto.reference.id))){
                conti.add(conto.reference.id);
              }
            }
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Dati dal database'),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Mostra Categorie'),
            onPressed: () {
              // Navigate to second route when tapped.
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VisualizzaCatPage()));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: FutureBuilder(
                    future: getConti(),
                    builder: (context, snapshot){
                      return ListView.builder(
                          itemCount: conti.length,
                          itemBuilder: (context, index){
                            return ListTile(
                              title: GetConto(idConto: conti[index]),
                            );
                          });
                    })
            )
          ],
        ),
      ),
    );
  }
}