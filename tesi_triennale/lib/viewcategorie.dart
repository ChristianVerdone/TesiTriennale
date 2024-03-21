import 'package:cloud_firestore/cloud_firestore.dart';
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

  List<String> cat = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Categorie'),
        actions: <Widget>[
          const SizedBox(width: 16),
          IconButton(
              onPressed: (){
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              icon: const Icon(Icons.home)),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: FutureBuilder(
                    future: getCat(),
                    builder: (context, snapshot){
                      return ListView.builder(
                          itemCount: cat.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => ViewContiCatPage(idCat: cat.elementAt(index))));
                                  },
                                  child: Text(cat.elementAt(index))
                              ),
                            );
                          }
                      );
                    }
                )
            )],
        ),
      ),
    );
  }

  getCat() async {
    await FirebaseFirestore.instance.collection('categorie').get().then(
            (value) => value.docs.forEach((categ) => cat.add(categ.id))
    );
  }
}