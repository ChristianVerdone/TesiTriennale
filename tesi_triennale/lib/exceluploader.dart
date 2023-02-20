import 'dart:html';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ExcelFilePage extends StatefulWidget {
  @override
  _ExcelFilePageState createState() => _ExcelFilePageState();
}

class _ExcelFilePageState extends State<ExcelFilePage> {
  List<int> _bytes = [];

  void _selectExcelFile() {
    final uploadInput = FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      final file = uploadInput.files!.first;
      final reader = FileReader();

      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((event) async {
        final storageRef = FirebaseStorage.instance.ref().child(file.name);

        await storageRef.putData(reader.result as Uint8List);
        final downloadUrl = await storageRef.getDownloadURL();
        print('File caricato su Firebase Storage: $downloadUrl');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleziona file Excel'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _selectExcelFile,
              child: Text('Seleziona file Excel'),
            ),
            SizedBox(height: 20),
            if (_bytes != null)
              Text('Hai selezionato un file Excel con ${_bytes.length} byte.'),
          ],
        ),
      ),
    );
  }
}
