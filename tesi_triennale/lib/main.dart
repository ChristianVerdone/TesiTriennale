import 'dart:html';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:csv/csv.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.indigo,
      ),
      home: const MyHomePage(title: 'tesi triennale'), //titolo dell'applicazione
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Carica file'),
              onPressed: () {
                // Navigate to second route when tapped.
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SecondRoute()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SecondRoute extends StatefulWidget { //seconda page di caricamento di un file csv per caricare dati sul database
  const SecondRoute({super.key});
  @override
  State<SecondRoute> createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {

  @override
  void initState() {
    super.initState();
  }

  List<List<dynamic>>? csvData;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carica file'),
      ),
      body: Column(
        children: [
          Container(
            child:  SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: csvData == null
              ? const CircularProgressIndicator() : DataTable(columns: csvData![0].map(
                (item) => DataColumn(
                  label: Text(
                    item.toString(),
                  ),
                ),
              ).toList(),
              rows: csvData!.getRange(1, csvData!.length).map(
                (csvrow) => DataRow(
                  cells: csvrow.map(
                    (csvItem) => DataCell(
                      Text(
                        csvItem.toString(),
                      ),
                    ),
                  ).toList(),
                ),
              ).toList(),
            ),
          ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          csvData = await processCsvFromFile();
          setState(() {});
          tooltip: 'carica';
          child: const Icon(Icons.arrow_upward);
        },
      ),
    );
  }

  Future<List<List<dynamic>>> processCsvFromFile() async {
    Uint8List? byteData = null;
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false,
        allowedExtensions: ['csv'], type: FileType.custom);

    if(result != null){
      byteData = result.files.first.bytes;
      print(byteData);
    }
    String result2 = new String.fromCharCodes(byteData as Iterable<int>);
    result2 = result2.replaceAll('ï»¿', '');
    print(result2);
    List<List<dynamic>> data = CsvToListConverter().convert(result2, eol: "\n", fieldDelimiter: ';');
    writedataFile(data);
    return data;
  }

  void writedataFile(List<List<dynamic>> data) async {
    for(final line in data){
      String numConto = line[0];
      numConto.replaceAll('ï»¿', '');
      String s = generateRandomString(5);

      final doc = FirebaseFirestore.instance.collection(numConto).doc(numConto+s);
      final json = {
        'Codice Conto' : numConto,
        'Descrizione conto' : line[1],
        'Data operazione' : line[2],
        'COD' : line[3],
        'Descrizione operazione' : line[4],
        'Numero documento' : line[5],
        'Data documento' : line[6],
        'Numero Fattura' : line[7],
        'Importo' : line[8],
        'Saldo' : line[9],
        'Contropartita' : line[10],
        'Costi Diretti' : null,
        'Costi Indiretti' : null,
        'Attività economiche' : null,
        'Attività non economiche' : null,
        'Codice progetto' : null
      };
      await doc.set(json);
    }
  }

  String generateRandomString(int len) {
    var r = Random();
    return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
  }
}