import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tesi_triennale/readData/getConto.dart';

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

  List<String> attribute = [ 'Materie Prime', 'Servizi', 'God beni terzi', 'Ammortamenti', 'Oneri diversi'];

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
                          itemCount: attribute.length,
                          itemBuilder: (context, index){
                            return ListTile(
                              title:  TextButton(
                                onPressed: (){
                                  //Navigator.push(context, MaterialPageRoute(builder: (context) => VisualizzaConto(idConto: this.idConto)));
                              },
                              child: Text(attribute.elementAt(index))
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