import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Get_Progetto.dart';
import 'insert_Progetto.dart';

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
        MaterialPageRoute(builder: (context) => const VisualizzaProg(),),
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
                  String refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => const InsertProgetto() ));
                  if(refresh == 'refresh'){
                    reload();
                  }
                },
                child: const Icon(Icons.add)
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              onPressed: () {
                // Printing.layoutPdf(onLayout: (pageFormat) {
                //   final doc = pw.Document();
                //   doc.addPage(pw.Page(
                //    build: (context) => Center(
                //     child: Text('Hello, World!'),
                //     ),
                //   ));
                //    return doc.save();
                //  });
              },
              child: const Icon(Icons.print),
            ),
            IconButton(
                onPressed: (){
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                icon: const Icon(Icons.home)),
            const SizedBox(width: 16),
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
                  if(progetto.reference.id != 'DefaultProject'){
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
                      'Percentuale' : perc.toStringAsFixed(2),
                    };
                    progetto.reference.update(json);
                    perc = 0;
                  }
            }
        )
    );
  }

  Future<void> valuatetot() async {
    await FirebaseFirestore.instance.collection('progetti').get().then(
            (snap) => snap.docs.forEach(
                (progetto) {
                  if(progetto.reference.id != 'DefaultProject'){
                    if(progetto.get('isEconomico')){
                      totProgettiE = totProgettiE + num.parse(progetto.get('Valore').toString());
                    }
                    else{
                      totProgettinE = totProgettinE + num.parse(progetto.get('Valore').toString());
                    }
                  }
            }
        )
    );
  }
}