import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/Progetto.dart';

class VisualizzaProgetto extends StatelessWidget{

  VisualizzaProgetto({super.key, required this.p});
  Progetto p;
  List<String> categories= [];
  num n = 0;
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
          actions: <Widget>[
            ElevatedButton(
                onPressed: (){
                  evaluate(p.nomeProgetto);
                },
                child: const Text('Calcola costi')
            )
          ],
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
                    const SizedBox(
                      height: 20,
                    ),
                    const Text('Costi Diretti:', textAlign: TextAlign.left),
                    Expanded(
                        child:  ListView.builder(
                            itemCount: p.costiDiretti.length,
                            itemExtent: 40,
                            itemBuilder: (context, index){
                              return ListTile(
                                visualDensity: VisualDensity.compact,
                                title: Text('${p.costiDiretti.keys.elementAt(index)}: ${p.costiDiretti.values.elementAt(index)}'),
                              );
                            }
                        ),
                    ),
                    Text('Totale:${n = getSum(p.costiDiretti.values)}'),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text('Costi Indiretti:', textAlign: TextAlign.left),
                    Expanded(
                        child: ListView.builder(
                            itemCount: p.costiIndiretti.length,
                            itemExtent: 40,
                            itemBuilder: (context, index){
                              return ListTile(
                                visualDensity: VisualDensity.compact,
                                title: Text('${p.costiIndiretti.keys.elementAt(index)}: ${p.costiIndiretti.values.elementAt(index)}'),
                              );
                            }
                        )
                    ),
                    Text('Totale:${n = getSum(p.costiIndiretti.values)}'),
                    const SizedBox(
                      height: 20,
                    ),
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

  num getSum(Iterable<dynamic> iterable) {
    n = 0;
    iterable.forEach((element) {
      n = n + num.parse(element) ;
    });
    return n;
  }

  evaluate(String nomeProgetto) async {
    num s;
    for (var element in p.costiDiretti.keys) {
      s = 0;
      await FirebaseFirestore.instance.collection('categorie').doc(element).get().then(
              (value) {
                (value.get('Conti') as List<dynamic>).forEach((element) async {
                  await FirebaseFirestore.instance.collection('${element.toString()}/lineeConto').get().then(
                          (value) => value.docs.forEach(
                                  (linea) {
                                    if(linea.get('Codice progetto').toString() == nomeProgetto && linea.get('Costi Diretti') == true){
                                      print('valore linea ${linea.get('Importo')}');
                                      s = s + num.parse(linea.get('Importo'));
                                      print('importo: $s');
                                    }
                                  }
                          )
                  );
                });
              }
      );
      p.costiDiretti.update(element, (value) => s.toString());
      print(p.costiDiretti[element]);
    }
  }
}