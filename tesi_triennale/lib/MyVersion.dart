import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, Uint8List;
import 'package:csv/csv.dart';

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
        body: Center(
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
        )
    );
  }

  Future<List<List<dynamic>>> processCsvFromFile() async {
    Uint8List? byteData;
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false,
        allowedExtensions: ['csv'], type: FileType.custom);

    if(result != null){
      byteData = result.files.first.bytes;
      print(byteData);
    }
    String result2 = String.fromCharCodes(byteData as Iterable<int>);
    result2 = result2.replaceAll('ï»¿', '');
    print(result2);
    List<List<dynamic>> data = const CsvToListConverter().convert(result2, eol: "\n", fieldDelimiter: ';');
    writedataFile(data);
    return data;
  }

  void writedataFile(List<List<dynamic>> data) async {
    for(final line in data){
      String numConto = line[0];
      numConto.replaceAll('ï»¿', '');
      if(numConto != 'Codice Conto'){
        String s = generateRandomString(5);
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

        await FirebaseFirestore.instance.collection('conti').doc(numConto).collection('lineeConto').doc(numConto+s).set(json);
      }
    }
  }

  String generateRandomString(int len) {
    var r = Random();
    return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
  }
}

class ShowFile extends StatelessWidget{
  final List<List<dynamic>> csvData;
  ShowFile({super.key, required this.csvData});


  final ScrollController controller1 = ScrollController();
  final ScrollController controller2 = ScrollController();

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
        title: const Text("Visualizzazione File",
            style: TextStyle(color: Colors.white,
              fontSize: 20.0, )
        ),
      ),
      body: Scrollbar(
        controller: controller2,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: controller2,
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            controller: controller1,
            child: DataTable(
              columns: csvData[0]
                  .map(
                    (item) => DataColumn(
                  label: Text(
                    item.toString(),
                  ),
                ),
              )
                  .toList(),
              rows: csvData!.getRange(1, csvData!.length)
                  .map(
                    (csvrow) => DataRow(
                  cells: csvrow
                      .map(
                        (csvItem) => DataCell(
                      Text(
                        csvItem.toString(),
                      ),
                    ),
                  )
                      .toList(),
                ),
              )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
