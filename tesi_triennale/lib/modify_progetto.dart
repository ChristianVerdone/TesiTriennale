import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tesi_triennale/visualizza_progetti.dart';
import 'progetto.dart';

class ModifyProgetto extends StatefulWidget{
  final Progetto progetto;

  const ModifyProgetto({super.key, required this.progetto});

  @override
  State<ModifyProgetto> createState() => _ModifyProgettoState();
}

class _ModifyProgettoState extends State<ModifyProgetto> {
  @override
  Widget build(BuildContext context ) => Scaffold(
    appBar: AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      actions: <Widget>[
        const SizedBox(width: 16),
        ElevatedButton(
          child: const Text('Applica'),
          onPressed: () async {
            final json = {
              'Anno' : widget.progetto.anno,
              'Valore' : widget.progetto.valore,
              'Costi Diretti' : widget.progetto.costiDiretti,
              'Costi Indiretti' : widget.progetto.costiIndiretti,
              'isEconomico' : widget.progetto.isEconomico,
              'Percentuale' : widget.progetto.perc,
              'Contributo Competenza' : widget.progetto.contributo,
              'CostiDirettiValue' : widget.progetto.references
            };
            setFunction(json);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const VisualizzaProg()));
          },
        ),
      ],
      centerTitle: true,
      title: Text('Modifica Progetto: ${widget.progetto.nomeProgetto}',
        style: const TextStyle(color: Colors.black,
          fontSize: 20.0)
      ),
    ),
    body: Column(
      children: [
        const SizedBox(height: 20),
        const Text('Anno:'),
        TextFormField(
          controller: TextEditingController(text: widget.progetto.anno),
          onFieldSubmitted: (value) {
            setState(() {
              widget.progetto.anno = value;
            });
          },
        ),
        const SizedBox(height: 20),
        const Text('is Economico:'),
        Checkbox(
          key: GlobalKey(),
          value: widget.progetto.isEconomico,
          onChanged: (bool? value) {
            setState(() {
              widget.progetto.isEconomico = value!;
            });
          },
        ),
        const SizedBox(height: 20),
        const Text('Contributo di Competenza:'),
        TextFormField(
          controller: TextEditingController(text: widget.progetto.contributo),
          onFieldSubmitted: (value) {
            setState(() {
              widget.progetto.contributo = value;
            });
          },
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$'))
          ],
        ),
        const SizedBox(height: 20),
        const Text('Valore:'),
        TextFormField(
          controller: TextEditingController(text: widget.progetto.valore),
          onFieldSubmitted: (value) {
            setState(() {
              widget.progetto.valore = value;
            });
          },
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$'))
          ],
        ),
      ]
    ),
  );

  Future<void> setFunction(Map<String, dynamic> json) async {
    await FirebaseFirestore.instance.collection('progetti').doc(widget.progetto.nomeProgetto).set(json);
  }
}