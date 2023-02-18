import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, Uint8List;
import 'package:csv/csv.dart';
import 'package:tesi_triennale/view/viewcategorie.dart';
import 'view/ShowDatabase.dart';
import 'view/ShowFile.dart';

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
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => FirebaseAuth.instance.signOut() )
          ],
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
                  child: const Text('Mostra Categorie'),
                  onPressed: () {
                    // Navigate to second route when tapped.
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const VisualizzaCatPage()));
                  },
                ),
              ),
            ),
            Container(
              child: SizedBox(
                height: 30,
              ),
            ),
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
          s = 'line_00';
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
          'Costi Diretti' : line[11],
          'Costi Indiretti' : line[12],
          'Attività economiche' : line[13],
          'Attività non economiche' : line[14],
          'Codice progetto' : line[15]
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