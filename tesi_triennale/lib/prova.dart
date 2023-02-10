import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, Uint8List;
import 'package:csv/csv.dart';

void main() => runApp(const MyApp());

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
    //(data);
    return data;
  }
}

class ShowFile extends StatelessWidget{
  final List<List<dynamic>> csvData;
  ShowFile({super.key, required this.csvData});


  final ScrollController ciccio = ScrollController();
  final ScrollController ciccio2 = ScrollController();

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
        controller: ciccio2,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: ciccio2,
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            controller: ciccio,
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
              rows: csvData
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
