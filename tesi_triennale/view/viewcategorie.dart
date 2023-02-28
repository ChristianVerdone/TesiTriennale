import 'package:flutter/material.dart';
import 'ViewContiCat.dart';

class VisualizzaCatPage extends StatefulWidget { //seconda page di caricamento di dati dal database
  const VisualizzaCatPage({super.key});
  @override
  State<VisualizzaCatPage> createState() => _VisualizzaCatPageState();
}

class _VisualizzaCatPageState extends State<VisualizzaCatPage>{

  @override
  void initState() {
    super.initState();
  }

  List<String> cat = [ 'Materie Prime', 'Servizi', 'God beni terzi', 'Ammortamenti', 'Oneri diversi', 'Personale'];

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
                    builder: (context, snapshot){
                      return ListView.builder(
                          itemCount: cat.length,
                          itemBuilder: (context, index){
                            return ListTile(
                              title:  TextButton(
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewContiCatPage(idCat: cat.elementAt(index))));
                              },
                              child: Text(cat.elementAt(index))
                              ),
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