import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tesi_triennale/readData/getConto.dart';

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
              print(conto.reference);
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