import 'dart:html';

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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
      writedata(_counter);
    });
  }

  void writedata(int data) async {
    final doc = FirebaseFirestore.instance.collection('numbers').doc('nuovo');
    final json = {
      'numero' : data
    };
    await doc.set(json);
  }

  void readCSV(){

  }

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
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
  late final file;
  void _pickFile() async {
    // opens storage to pick files and the picked file or files
    // are assigned into result and if no file is chosen result is null.
    // you can also toggle "allowMultiple" true or false depending on your need
    final file = await FilePicker.platform.pickFiles(allowMultiple: false);
    // if no file is picked
    if (file == null) return;
    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
    print(file.files.first.name);
    print(file.files.first.size);
    print(file.files.first.path);
  }

  List<List<dynamic>>? csvData;
  Future<List<List<dynamic>>> processCsv() async {
    var result2 = await DefaultAssetBundle.of(context).loadString(
      "assets/outProvamix.csv",
    );
    return const CsvToListConverter().convert(result2, eol: "\n", fieldDelimiter: ';');
  }

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
          ElevatedButton(
            onPressed: () async{
              // Navigate back to first route when tapped.
              csvData = await processCsvFromFile();
              setState(() {});
            },
            child: const Text('carica'),
          ),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: csvData == null
              ? const CircularProgressIndicator() : DataTable(columns: csvData![0].map(
                (item) => DataColumn(
                  label: Text(
                    item.toString(),
                  ),
                ),
              ).toList(),
              rows: csvData!.map(
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          csvData = await processCsvFromFile();
          setState(() {});
        },
      ),
    );
  }

  Future<List<List<dynamic>>> processCsvFromFile()async{
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, allowedExtensions: ['csv'], type: FileType.custom);
    if (result != null) {
       File file = File(result.files.first.bytes as List<Object>, result.files.first.name);
    } else {
      // User canceled the picker
    }
    return const CsvToListConverter().convert(file, eol: "\n", fieldDelimiter: ';');
  }
}