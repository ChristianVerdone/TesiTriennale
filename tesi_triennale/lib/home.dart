import 'dart:async';
import 'dart:html';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, Uint8List;
import 'package:csv/csv.dart';
import 'Conto.dart';
import 'utils.dart';
import 'ShowFile.dart';
import 'VisualizzaProgetti.dart';
import 'show_database.dart';

class HomePage extends StatefulWidget{
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _homePageState();
}

class _homePageState extends State<HomePage>{
  List<Conto> conti = [];
  List<Map<String, dynamic>> csvData2 = [];
  List<List<dynamic>>? csvData;
  String? filePath;
  Timer scheduleTimeout([int milliseconds = 10000]) =>
      Timer(Duration(milliseconds: milliseconds), handleTimeout);
  Timer scheduleTimeout2([int milliseconds = 10000]) =>
      Timer(Duration(milliseconds: milliseconds), handleTimeout2);
  Timer scheduleTimeout3([int milliseconds = 10000]) =>
      Timer(Duration(milliseconds: milliseconds), handleTimeout3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => FirebaseAuth.instance.signOut() ),
          ],
          systemOverlayStyle: const SystemUiOverlayStyle(
            // Status bar color
            statusBarColor: Colors.blue,
            // Status bar brightness (optional)
            statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
          centerTitle: true,
          title: const Text("Home",
              style: TextStyle(color: Colors.black,
                fontSize: 20.0, )
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: ElevatedButton(
                child: const Text("Carica file"),
                onPressed: () async {
                    await _selectExcelFile().then((value) async {
                      scheduleTimeout(20*1000);
                      scheduleTimeout2(40*1000);
                      scheduleTimeout3(80*1000);
                    });
                },
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: ElevatedButton(
                child: const Text('Visualizza Conti'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => VisualizzaPage()));
                },
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: ElevatedButton(
                child: const Text('Visualizza Progetti'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const VisualizzaProg()));
                },
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        )
    );
  }

  Future getAll() async{
    await FirebaseFirestore.instance.collection('conti/').get().then((snapshot) => snapshot.docs.forEach((conto) {
      getLines(conto.id);
    }));
    conti = convertMapToObject(csvData2);
  }

  Future getLines(String idConto) async {
    await FirebaseFirestore.instance
        .collection('conti/$idConto/lineeConto')
        .get()
        .then((snapshot) => snapshot.docs.forEach((linea) {
      //print(linea.reference);
      Map<String, dynamic> c = {
        'Codice Conto': linea.get('Codice Conto'),
        'Descrizione conto': linea.get('Descrizione conto'),
        'Data operazione': linea.get('Data operazione'),
        'COD': linea.get('COD'),
        'Descrizione operazione': linea.get('Descrizione operazione'),
        'Numero documento': linea.get('Numero documento'),
        'Data documento': linea.get('Data documento'),
        'Numero Fattura': linea.get('Numero Fattura'),
        'Importo': linea.get('Importo'),
        'Saldo': linea.get('Saldo'),
        'Contropartita': linea.get('Contropartita'),
        'Costi Diretti': linea.get('Costi Diretti'),
        'Costi Indiretti': linea.get('Costi Indiretti'),
        'Attività economiche': linea.get('Attività economiche'),
        'Attività non economiche': linea.get('Attività non economiche'),
        'Codice progetto': linea.get('Codice progetto')
      };
      csvData2.add(c);
    }));
  }

  Future<void> handleTimeout() async {  // callback function
    if(i == 1) {
      fetchHello();
    }
  }

  Future<void> handleTimeout2() async {
    if(i==1) {
      csvData = await processCsvFromFile();
    }
  }

  void handleTimeout3(){
    if(i==1) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ShowFile(csvData: csvData!)));
    }
    else{
        setState(() {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        });
    }
  }

  late int i;

  void fetchHello() async {
    Map<String, String> headers = {
      "Content-Type": "text/plain",
    };
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/'), headers: headers);
    if(response.statusCode == 200){
      setState(() {});
    }
  }

  _selectExcelFile() async{
    i = 0;
    var uploadInput = FileUploadInputElement();
    uploadInput.click();
    uploadInput.onChange.listen((event) async {
      final file = uploadInput.files!.first;
      final reader = FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((event) async {
        i=1;
        var storageRef = FirebaseStorage.instance.ref('source.xls');
        await storageRef.putData(reader.result as Uint8List);
        final downloadUrl = await storageRef.getDownloadURL();
        print('File caricato su Firebase Storage: $downloadUrl''i: $i');
      });
    });
  }

  Future<List<List<dynamic>>> processCsvFromFile() async {
    Uint8List? byteData;
    var storageRef = FirebaseStorage.instanceFor(bucket: 'tesitriennale-4d2f1.appspot.com').ref('file.csv');
    await storageRef.getDownloadURL().then((value) => print(value));
    byteData = await storageRef.getData();
    String result2 = String.fromCharCodes(byteData as Iterable<int>);
    result2 = result2.replaceAll('ï»¿', '');
    List<List<dynamic>> data = const CsvToListConverter().convert(result2, eol: "\n", fieldDelimiter: ',');
    writedataFile(data);
    return data;
  }

  Future<int> writedataFile(List<List<dynamic>> data) async {
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
          'Costi Diretti' : false,
          'Costi Indiretti' : true,
          'Attività economiche' : false,
          'Attività non economiche' : false,
          'Codice progetto' : line[15]
        };
        String iS = i.toString();
        if(i>9){
          s = 'line_0';
        }
        if(i>99){
          s = 'line_';
        }
        i++;
        await FirebaseFirestore.instance.collection('conti').doc(numConto).collection('lineeConto').doc(numConto+s+iS).set(json);
      }
    }
    return i;
  }
}