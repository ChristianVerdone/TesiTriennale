import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/Progetto.dart';

class VisualizzaProgetto extends StatelessWidget{

  VisualizzaProgetto({super.key, required this.p});
  Progetto p;
  List<String> categories= [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            // Status bar color
            statusBarColor: Colors.white,
            // Status bar brightness (optional)
            statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
          centerTitle: true,
          title: Text('Visualizzazione Progetto: ${p.nomeProgetto}',
              style: const TextStyle(color: Colors.white,
                fontSize: 20.0, )
          ),
        ),
        body: FutureBuilder(
          future: getCat(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.done){
            return Center(
                child: Column(
                  children: [
                    Text('Anno: ${p.anno}'),
                    Text('Valore: ${p.valore}'),
                    const Text('Costi Diretti:', textAlign: TextAlign.left),
                    Expanded(
                        child:  ListView.builder(
                            itemCount: p.costiDiretti.length,
                            itemBuilder: (context, index){
                              return ListTile(
                                title: Text('${p.costiDiretti.keys.elementAt(index)}: ${p.costiDiretti.values.elementAt(index)}'),
                              );
                            }
                        ),
                    ),
                    const Text('Costi Indiretti:', textAlign: TextAlign.left),
                    Expanded(
                        child: ListView.builder(
                            itemCount: p.costiIndiretti.length,
                            itemBuilder: (context, index){
                              return ListTile(
                                title: Text('${p.costiIndiretti.keys.elementAt(index)}: ${p.costiIndiretti.values.elementAt(index)}'),
                              );
                            }
                        )
                    )
                  ],
                ),
            );
            }
            return const Center(
              child: Text('loading...'),
            );
          },
        )
    );
  }

   getCat() async {
    await FirebaseFirestore.instance.collection('categorie').get().then((value) {
      for (var element in value.docs) { 
        categories.add(element.id);
      }
    });
  }
}