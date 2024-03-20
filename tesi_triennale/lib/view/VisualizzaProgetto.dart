import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../ModifyProgetto.dart';
import '../model/Progetto.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

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
            const SizedBox(width: 16),
            IconButton(
                onPressed: (){

                },
                icon: const Icon(Icons.remove)),
            ElevatedButton(
              child: const Text('Modifica'),
              onPressed: () async {
                String refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        //FixedHeaderDataTable(columns: columns, rows: rows)));
                        ModifyProgetto(progetto: p)));
              },
            ),
            IconButton(
                onPressed: () {
                  Printing.layoutPdf(onLayout: (format) => _generatePdfContent());
                },
                icon: const Icon(Icons.print),
            ),
            IconButton(
                onPressed: (){
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                icon: const Icon(Icons.home)),
            const SizedBox(width: 16),
            ElevatedButton(
                onPressed: () async {
                  await evaluate(p.nomeProgetto);
                  Navigator.of(context).pop(true);
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
                    Text('| Anno: ${p.anno} | Valore: ${p.valore} | isEconomico: ${p.isEconomico.toString()} | '
                        'Contributo di competenza: ${p.contributo} |',
                    ),
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

  FutureOr<Uint8List> _generatePdfContent() async{
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      margin: const pw.EdgeInsets.all(3),
      build: (pw.Context context) {
        return pw.Center(
           child: pw.Column(
          children: [
            pw.Text('${p.nomeProgetto}'),
            pw.Text('Anno: ${p.anno} | Valore: ${p.valore} | isEconomico: ${p.isEconomico.toString()} | '
                'Contributo di competenza: ${p.contributo}',
            ),
            pw.SizedBox(
              height: 10
            ),
            pw.Text('Costi Diretti:', textAlign: pw.TextAlign.left),
            pw.ListView.builder(
                  itemCount: p.costiDiretti.length,
                  itemBuilder: (context, index){
                    return pw.Container(
                      child: pw.Text('${p.costiDiretti.keys.elementAt(index)}: ${p.costiDiretti.values.elementAt(index)}'),
                    );
                  }
              ),
            pw.Text('Totale:${n = getSum(p.costiDiretti.values)}'),
            pw.SizedBox(
              height: 10,
            ),
            pw.Text('Costi Indiretti:', textAlign: pw.TextAlign.left),
            pw.ListView.builder(
                    itemCount: p.costiIndiretti.length,
                    itemBuilder: (context, index){
                      return pw.Container(
                        child: pw.Text('${p.costiIndiretti.keys.elementAt(index)}: ${p.costiIndiretti.values.elementAt(index)}'),
                      );
                    }
                ),
            pw.Text('Totale:${n = getSum(p.costiIndiretti.values)}'),
          ],
        ));
      },
    ));

    return pdf.save();
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
    for (var element in iterable) {
      n = n + num.parse(element) ;
    }
    return n;
  }

  evaluate(String nomeProgetto) async {
    num s;
    for (var categoria in p.costiDiretti.keys) {
      s = 0;
      await FirebaseFirestore.instance.collection('categorie').doc(categoria).get().then(
              (cat) async {
                for (var element in (cat.get('Conti') as List<dynamic>)){
                  DocumentReference d = element as DocumentReference;
                  await FirebaseFirestore.instance.collection('conti/${d.id}/lineeConto').get().then(
                          (value) => value.docs.forEach(
                                  (linea) {
                                    if(linea.get('Codice progetto').toString() == nomeProgetto && linea.get('Costi Diretti') == true){
                                      s = s + num.parse(linea.get('Importo').toString());
                                    }
                                  }
                          )
                  );
                }
              }
      );
      p.costiDiretti.update(categoria, (value) => s.toStringAsFixed(2));
    }
    num totCostiIndAE = 0;
    num totCostiIndAnE = 0;
    await FirebaseFirestore.instance.collection('categorie').get().then(
            (snap) => snap.docs.forEach(
                    (cat) {
                      totCostiIndAE = totCostiIndAE + num.parse(cat.get('Totale Costi Indiretti A E').toString());
                      totCostiIndAnE = totCostiIndAnE + num.parse(cat.get('Totale Costi Indiretti A nE').toString());
                    }
            )
    );
    for (var categoria in p.costiIndiretti.keys) {
      s = 0;
      await FirebaseFirestore.instance.collection('categorie').doc(categoria).get().then(
              (cat) {
                if(p.isEconomico){
                  s = num.parse(p.perc.toString()) / 100 * totCostiIndAE * num.parse(cat.get('Percentuale CI A E').toString()) / 100;
                }
                else{
                  s = num.parse(p.perc.toString()) / 100 * totCostiIndAnE * num.parse(cat.get('Percentuale CI A nE').toString()) / 100;
                }
              }
      );
      p.costiIndiretti.update(categoria, (value) => s.toStringAsFixed(2));
    }
    final json = {
      'Costi Diretti' : p.costiDiretti,
      'Costi Indiretti' : p.costiIndiretti,
    };
    await FirebaseFirestore.instance.collection('progetti').doc(nomeProgetto).update(json);
  }
}