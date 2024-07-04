import 'dart:async';
import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, Uint8List;
import 'package:csv/csv.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'conto.dart';
import 'utils.dart';
import 'visualizza_progetti.dart';
import 'show_database.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>{
  List<Conto> conti = [];
  List<Map<String, dynamic>> csvData2 = [];
  List<List<dynamic>>? csvData;
  String? filePath;
  final String _loadingMessage = "Caricamento in corso...";
  bool _isFileErroredExists = false;
  bool caricamento = false;
  late int i;
  var storageRef;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut()
          ),
        ],
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.blue,
        ),
        centerTitle: true,
        title: const Text("Home", style: TextStyle(color: Colors.black, fontSize: 20.0, )),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: ElevatedButton(
              child: const Text("Carica file"),
              onPressed: () async {
                _showLoadingDialog(context);
                await _selectExcelFile();
              },
            ),
          ),
          const SizedBox(height: 30),
          if(_isFileErroredExists)
            Center(
              child: Column(
                children:[
                  const Text('Il file errored è disponibile per il download',
                    style: TextStyle(color: Colors.red, fontSize: 20.0,)
                  ),
                  ElevatedButton(
                    child: const Text('Scarica file errored'),
                    onPressed: () {
                      downloadFile(storageRef.getDownloadURL().toString());
                    },
                  ),
                  const SizedBox(height: 30),
                  const Text('Carica un nuovo file per aggiungere i dati mancanti al database',
                    style: TextStyle(color: Colors.red, fontSize: 20.0,)
                  ),
                  Center(
                    child: ElevatedButton(
                      child: const Text('Carica file integrazione'),
                      onPressed: () {
                        _uploadAndProcessFile();
                      },
                    ),
                  ),
                ]
              )
            ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              child: const Text('Visualizza Conti'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => VisualizzaPage()));
              },
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              child: const Text('Carica Progetti'),
              onPressed: () {
                //_processFileProgetti();
              },
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              child: const Text('Visualizza Progetti'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const VisualizzaProg()));
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
      )
    );
  }

  Future<void> _uploadAndProcessFile() async {
    // Apri il selettore di file
    var uploadInput = FileUploadInputElement();
    uploadInput.click();
    uploadInput.onChange.listen((event) async {
      final file = uploadInput.files!.first;
      final reader = FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((event) async {
        // Carica il file su Firebase
        var storageRef = FirebaseStorage.instance.ref('fix.xlsx');
        await storageRef.putData(reader.result as Uint8List);
        final downloadUrl = await storageRef.getDownloadURL();
        if (kDebugMode) {
          print('File caricato su Firebase Storage: $downloadUrl');
        }
        // Invia una richiesta al server Flask per elaborare il file
        Map<String, String> headers = {
          "Content-Type": "text/plain",
        };
        final response = await http.get(
            Uri.parse('http://127.0.0.1:5000/procFix'),
            headers: headers
        );
        if (response.statusCode == 200) {
          if (kDebugMode) {
            print('File elaborato con successo');
          }
          await processCsvFromFix();
          setState(() { });
        } else {
          if (kDebugMode) {
            print('Errore durante l\'elaborazione del file');
          }
        }
      });
    });
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text(_loadingMessage),
                ElevatedButton(
                  onPressed: () {
                    _hideLoadingDialog(context);
                  },
                  child: const Text('chiudi')
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future getAll() async{
    await FirebaseFirestore.instance.collection('conti/').get().then(
      (snapshot) => snapshot.docs.forEach((conto) {
        getLines(conto.id);
      })
    );
    conti = convertMapToObject(csvData2);
  }

  Future getLines(String idConto) async {
    await FirebaseFirestore.instance.collection('conti/$idConto/lineeConto').get().then(
      (snapshot) => snapshot.docs.forEach((linea) {
        Map<String,dynamic> c = linea.data();
        csvData2.add(c);
      })
    );
  }

  Future<bool> checkIfFileExists() async {
    if (kDebugMode) {
      print('checkIfFileExists');
    }
    storageRef = FirebaseStorage.instance.ref('errored.xlsx');
    try {
      await storageRef.getDownloadURL();
      // Se non si verifica un errore, il file esiste
      return true;
    } catch (e) {
      // Se si verifica un errore, il file non esiste
      return false;
    }
  }

  void fetchHello() async {
    Map<String, String> headers = {
      "Content-Type": "text/plain",
    };
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/proc'), headers: headers);
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('File elaborato con successo');
      }
      bool b = await checkIfFileExists();
      setState(() {
        _isFileErroredExists = b;
      });
      if(i==1) {
        csvData = await processCsvFromFile();
      }
    }
  }

  void downloadFile(String url) async {
    // Crea un riferimento al file in Firebase Storage
    var storageRef = FirebaseStorage.instance.refFromURL(url);
    // Ottieni l'URL di download del file
    String? downloadUrl;
    try {
      downloadUrl = await storageRef.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Errore durante il recupero dell\'URL di download: $e');
      }
      return;
    }
    if (kDebugMode) {
      print('URL di download: $downloadUrl');
    }
    // Avvia il download del file aprendo l'URL nel browser
    if (await canLaunchUrlString(downloadUrl)) {
      await launchUrlString(downloadUrl);
    } else {
      if (kDebugMode) {
        print('Impossibile avviare il download del file: $downloadUrl');
      }
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
        var storageRef = FirebaseStorage.instance.ref('source.xlsx');
        await storageRef.putData(reader.result as Uint8List);
        final downloadUrl = await storageRef.getDownloadURL();
        if(downloadUrl.isNotEmpty){
          if(kDebugMode){
            print('File caricato su Firebase Storage: $downloadUrl');
          }
          await refreshData();
          fetchHello();
        }
      });
    });
  }

  Future<List<List<dynamic>>> processCsvFromFile() async {
    if (kDebugMode) {
      print('processCsvFromFile called');
    }
    Uint8List? byteData;
    var storageRef = FirebaseStorage.instanceFor(bucket: 'tesitriennale-4d2f1.appspot.com').ref('file.csv');
    await storageRef.getDownloadURL().then((value) => {
      print(value)
    });
    byteData = await storageRef.getData();
    String result2 = String.fromCharCodes(byteData as Iterable<int>);
    result2 = result2.replaceAll('ï»¿', '');
    List<List<dynamic>> data = const CsvToListConverter().convert(result2, eol: "\n", fieldDelimiter: ',');
    writedataFile(data);
    return data;
  }

  Future<int> writedataFile(List<List<dynamic>> data) async {
    if (kDebugMode) {
      print('writedataFile called');
    }
    int i = 0;
    String temp = '';
    String s = 'line_00';
    String numConto = '';
    for(final line in data){
      numConto = line[0];
      numConto.replaceAll('ï»¿', '');
      if(numConto != temp){
        temp = numConto;
        i = 0;
        s = 'line_00';
        if(numConto != 'Codice Conto') {
          await FirebaseFirestore.instance.collection('conti').doc(numConto).set({
            'Descrizione conto': line[1]
          });
        }
      }
      if(numConto != 'Codice Conto'){
        final json = {
          'Codice Conto' : numConto,
          'Descrizione conto' : line[1],
          'Data operazione' : line[2],
          'Descrizione operazione' : line[3],
          'Numero documento' : line[4],
          'Data documento' : line[5],
          'Importo' : line[6],
          'Saldo' : '',
          'Contropartita' : line[7],
          'Costi Diretti' : false,
          'Costi Indiretti' : true,
          'Attività economiche' : false,
          'Attività non economiche' : false,
          'Codice progetto' : ''
        };
        String iS = i.toString();
        if(i>9) s = 'line_0';
        if(i>99) s = 'line_';
        i++;
        await FirebaseFirestore.instance.collection('conti').doc(numConto).collection('lineeConto').doc(numConto+s+iS).set(json);
      }
    }
    return i;
  }

  processCsvFromFix() async {
    Uint8List? byteData;
    var storageRef = FirebaseStorage.instanceFor(bucket: 'tesitriennale-4d2f1.appspot.com').ref('fix.csv');
    await storageRef.getDownloadURL().then((value) => {
      print(value)
    });
    byteData = await storageRef.getData();
    String result2 = String.fromCharCodes(byteData as Iterable<int>);
    result2 = result2.replaceAll('ï»¿', '');
    List<List<dynamic>> data = const CsvToListConverter().convert(result2, eol: "\n", fieldDelimiter: ',');
    writedataFileInt(data);
    return data;
  }

  Future<void> writedataFileInt(List<List> data) async {
    int i = 0;
    String s = 'line_00';
    String numConto = '';
    for(final line in data){
      numConto = line[0];
      await getNumberOfDocuments(numConto).then((value) => {
        i = value,
        if(i>9){
          s = 'line_0',
          if(i>99) s = 'line_',
        }
        else s = 'line_00',
      });
      i++;
      if(numConto != 'Codice Conto'){
        final json = {
          'Codice Conto' : numConto,
          'Descrizione conto' : line[1],
          'Data operazione' : line[2],
          'Descrizione operazione' : line[3],
          'Numero documento' : line[4],
          'Data documento' : line[5],
          'Importo' : line[6],
          'Saldo' : '',
          'Contropartita' : line[7],
          'Costi Diretti' : false,
          'Costi Indiretti' : true,
          'Attività economiche' : false,
          'Attività non economiche' : false,
          'Codice progetto' : ''
        };
        String iS = i.toString();
        await FirebaseFirestore.instance.collection('conti').doc(numConto).collection('lineeConto').doc(numConto+s+iS).set(json);
      }
    }
  }

  Future<int> getNumberOfDocuments(String num) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('conti').doc(num).collection('lineeConto').get();
    return querySnapshot.docs.length;
  }

  refreshData() async {
    if (kDebugMode) {
      print('refreshData called');
    }
    await FirebaseFirestore.instance.collection('conti').get().then((snapshot) => snapshot.docs.forEach((conto) {
      conto.reference.collection('lineeConto').get().then((value) => {
        value.docs.forEach((linea) {
          linea.reference.delete();
        })
      });
    }));
  }
}