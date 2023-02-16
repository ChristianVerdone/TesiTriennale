import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tesi_triennale/readData/getConto.dart';
import 'package:tesi_triennale/view/ViewContiCat.dart';

class VisualizzaCatPage extends StatefulWidget { //seconda page di caricamento di dati dal database
  const VisualizzaCatPage({super.key});
  @override
  State<VisualizzaCatPage> createState() => _VisualizzaCatPageState();
}

class _VisualizzaCatPageState extends State<VisualizzaCatPage>{

  @override
  void initState() {
    super.initState();
  }

  List<String> attribute = [ 'Materie Prime', 'Servizi', 'God beni terzi', 'Ammortamenti', 'Oneri diversi'];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Dati dal database'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: FutureBuilder(
                    builder: (context, snapshot){
                      return ListView.builder(
                          itemCount: attribute.length,
                          itemBuilder: (context, index){
                            return ListTile(
                              title:  TextButton(
                                onPressed: (){
                                  findConti(attribute.elementAt(index));
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewContiCatPage(conti: conti)));
                              },
                              child: Text(attribute.elementAt(index))
                              ),
                            );
                          });
                    })
            )
          ],
        ),
      ),
    );
  }

  List<String> conti = [];

  Future findConti(String idcat) async {
    switch (idcat) {
      case 'Materie Prime':{
        conti = ['8.01.010', '8.11.011'];
      }break;
      case 'Servizi':{
        conti = ['8.01.009', '8.01.031', '8.04.010', '8.09.005', '8.11.013', '8.14.000', '8.14.001', '8.14.004', '8.14.007',
          '8.14.021', '8.14.024', '8.16.000', '8.16.019', '8.17.000', '8.18.000', '8.19.000'];
      }break;
      case 'God beni terzi':{
        conti = [' 8.12.000'];
      }break;
      case 'Ammortamenti':{
        conti = ['8.22.003', '8.22.005', '8.22.009', '8.22.010', '8.22.013', '8.22.015', '8.26.004'];
      }break;
      case 'Oneri diversi':{
        conti = ['8.11.000', '8.14.005', '8.14.010', '8.14.011', '8.15.005', '8.17.006', '8.20.002', '8.20.007', '8.20.010',
          '8.21.000', '8.21.005', '8.21.006', '8.36.001', '8.36.004', '8.37.010', '8.38.003', '8.38.004', '8.38.005',
          '8.38.012', '8.46.005', '8.46.007', '8.46.008', '8.46.009'];
      }break;
    }
  }
}