import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class insertProgetto extends StatelessWidget{
  String nomeProgetto = '';
  String anno = '';
  String valore = '';
  bool isEconomico = false;
  Map<String, dynamic> staticMap = {
    'Ammortamenti' : '0',
    'God beni terzi' : '0',
    'Materie Prime' : '0',
    'Oneri diversi' : '0',
    'Personale' : '0',
    'Servizi' : '0'
  };
  String percentuale = '0';
  String contributo = '';

  insertProgetto({super.key});

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
          title: const Text('Inserisci Progetto',
              style: TextStyle(color: Colors.white,
                fontSize: 20.0, )
          ),
          actions: <Widget>[
            ElevatedButton(
                onPressed: () async {
                  final json = {
                    'Anno' : anno,
                    'Valore' : valore,
                    'Costi Diretti' : staticMap,
                    'Costi Indiretti' : staticMap,
                    'isEconomico' : isEconomico,
                    'Percentuale' : percentuale,
                    'Contributo Competenza' : contributo
                  };
                  setFunction(json);
                  Navigator.pop(context, 'refresh');
                },
                child: const Text('Salva'))
          ],
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Inserisci il nome Progetto',
              ),
              validator: (value) {
                if (value == null) {
                  return 'Per favore inserisci il nome';
                }
                return null;
              },
              onFieldSubmitted: (value){
                nomeProgetto = value!;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Inserisci anno',
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              validator: (value) {
                if (value == null) {
                  return 'Per favore inserisci anno';
                }
                return null;
              },
              onFieldSubmitted: (value) {
                anno = value!;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Inserisci il Valore: euro',
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              validator: (value) {
                if (value == null) {
                  return 'Per favore inserisci il Valore';
                }
                return null;
              },
              onFieldSubmitted: (value) {
                valore = value!;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Inserisci il Contributo di Competenza dello stesso anno: euro',
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\-?\d*$'))
              ],
              validator: (value) {
                if (value == null) {
                  return 'Per favore inserisci il Valore';
                }
                return null;
              },
              onFieldSubmitted: (value) {
                valore = value!;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('è Economico:'),
            const SizedBox(
              height: 20,
            ),
            Checkbox(
              key: GlobalKey(),
              value: false,
              onChanged: (bool? value) {
                isEconomico = value!;
              },
            ),
          ],
        )
    );
  }

  Future<void> setFunction(Map<String, Object> json) async {
    await FirebaseFirestore.instance.collection('progetti').doc(nomeProgetto).set(json);
  }

}