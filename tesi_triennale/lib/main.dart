import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, Uint8List;
import 'package:csv/csv.dart';
import 'package:tesi_triennale/ModifyData.dart';
import 'view/ShowDatabase.dart';
import 'view/ShowFile.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Layout basic',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget{
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _homePageState();
}

class _homePageState extends State<HomePage>{
  List<List<dynamic>>? csvData;
  String? filePath;
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
          title: const Text("Home",
              style: TextStyle(color: Colors.white,
                fontSize: 20.0, )
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Center(
                child: ElevatedButton(
                  child: const Text("Carica file"),
                  onPressed: () async {
                    csvData = await processCsvFromFile();
                    setState(() {});
                    if(csvData != null){
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ShowFile(csvData : csvData!))
                      );
                    }
                  },
                ),
              ),
            ),
            Container(
              child: SizedBox(
                height: 30,
              ),
            ),
            Container(
              child: Center(
                child: ElevatedButton(
                  child: const Text('Visualizza Dati'),
                  onPressed: () {
                    // Navigate to second route when tapped.
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const VisualizzaPage()));
                  },
                ),
              ),
            ),
            Container(
              child: SizedBox(
                height: 30,
              ),
            ),
            Container(
              child: Center(
                child: ElevatedButton(
                  child: const Text('Modifica dati'),
                  onPressed: () {
                    // Navigate to second route when tapped.
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ModifyData()));
                  },
                ),
              ),
            )
          ],
        )
    );
  }

  Future<List<List<dynamic>>> processCsvFromFile() async {
    Uint8List? byteData;
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false,
        allowedExtensions: ['csv'], type: FileType.custom);
    if(result != null){
      byteData = result.files.first.bytes;
    }
    String result2 = String.fromCharCodes(byteData as Iterable<int>);
    result2 = result2.replaceAll('ï»¿', '');
    List<List<dynamic>> data = const CsvToListConverter().convert(result2, eol: "\n", fieldDelimiter: ';');
    writedataFile(data);
    return data;
  }

  void writedataFile(List<List<dynamic>> data) async {
    int i = 0;
    String temp = '';
    String s = 'line_00';
    String numConto = '';
    for(final line in data){
      numConto = line[0];
      numConto.replaceAll('ï»¿', '');
      if(numConto != 'Codice Conto'){
        if(numConto != temp){
          temp = numConto;
          i = 0;
        }
        await FirebaseFirestore.instance.collection('conti').doc(numConto).set({
          'Descrizione conto' : line[1]
        });
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
        String iS = i.toString();
        if(i>9){
          s = 'line_0';
        }
        if(i>99){
          s = 'line_';
        }
        await FirebaseFirestore.instance.collection('conti').doc(numConto).collection('lineeConto').doc(numConto+s+iS).set(json);
        i++;
      }
    }
  }
}

