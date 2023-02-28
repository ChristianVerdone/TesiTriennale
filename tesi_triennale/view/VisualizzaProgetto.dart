import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/Progetto.dart';

class VisualizzaProgetto extends StatelessWidget{

  String idProgetto;
  VisualizzaProgetto({super.key, required this.idProgetto});
  late Progetto p;

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
          title: Text('Visualizzazione Progetto: $idProgetto',
              style: const TextStyle(color: Colors.white,
                fontSize: 20.0, )
          ),
        ),
        body: FutureBuilder(
          future: getInformations(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              return Column(
                children: [
                  Text('Anno: ${p.anno}'),
                  Text('Valore: ${p.valore}'),
                  ListView.builder(
                      itemCount: p.costiDiretti.length,
                      itemBuilder: (context, index){
                        return ListTile(
                          title: Text('${p.costiDiretti[index].keys.first}: ${p.costiDiretti[index].values.first}'),
                        );
                      }),
                  ListView.builder(
                      itemCount: p.costiIndiretti.length,
                      itemBuilder: (context, index){
                        return ListTile(
                          title: Text('${p.costiIndiretti[index].keys.first}: ${p.costiIndiretti[index].values.first}'),
                        );
                      }),
                ],
              );
            }
            return const Center(
              child: Text('loading...'),
            );
          },
        )
    );
  }

  getInformations() {

  }
}