import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../readData/GetProgetto.dart';

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

  @override
  void dispose() {
    super.dispose();
  }

  List<String> progetti = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Progetti'),
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
    await FirebaseFirestore.instance.collection('progetti').get().then(
            (snapshot) => snapshot.docs.forEach(
                (progetto) {
              if(!(progetti.contains(progetto.reference.id))){
                progetti.add(progetto.reference.id);
              }
            }
        )
    );
  }
}