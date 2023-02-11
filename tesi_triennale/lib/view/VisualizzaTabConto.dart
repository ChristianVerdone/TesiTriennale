import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

class VisualizzaConto extends StatelessWidget{
  final List<List<dynamic>> csvData;
  VisualizzaConto({super.key, required this.csvData});


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
        title: const Text("Visualizzazione file caricato",
            style: TextStyle(color: Colors.white,
              fontSize: 20.0, )
        ),
      ),
      body: Scrollbar(
        controller: controller2,
        thumbVisibility: false,
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
              rows: csvData.getRange(1, csvData.length)
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