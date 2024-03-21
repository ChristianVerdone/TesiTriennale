
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Progetto.dart';

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
        // Status bar color
        statusBarColor: Colors.white,
        // Status bar brightness (optional)
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
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
              'Contributo Competenza' : widget.progetto.contributo
            };
            setFunction(json);
            Navigator.pop(context, 'refresh');
          },
        ),
      ],
      centerTitle: true,
      title: Text('Modifica Progetto: ${widget.progetto.nomeProgetto}',
          style: const TextStyle(color: Colors.white,
            fontSize: 20.0, )
      ),
    ),
    body: Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        const Text('Anno:'),
        TextField(
          controller: TextEditingController(text: widget.progetto.anno),
          onChanged: (value) {
            setState(() {
              widget.progetto.anno = value;
            });
          },
        ),
        const SizedBox(
          height: 20,
        ),
        const Text('is Economico:'),
        Checkbox(
          key: GlobalKey(),
          value: widget.progetto.isEconomico,
          onChanged: (bool? value) {
            widget.progetto.isEconomico = value!;
          },
        ),
        const SizedBox(
          height: 20,
        ),
        const Text('Contributo di Competenza:'),
        TextField(
          controller: TextEditingController(text: widget.progetto.contributo),
          onChanged: (value) {
            setState(() {
              widget.progetto.contributo = value;
            });
          },
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^\-?\d*\.?\d*$'))
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        const Text('Valore:'),
        TextField(
          controller: TextEditingController(text: widget.progetto.valore),
          onChanged: (value) {
            setState(() {
              widget.progetto.valore = value;
            });
          },
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
        ),
      ]
    ),
  );

  Future<void> setFunction(Map<String, dynamic> json) async {
    await FirebaseFirestore.instance.collection('progetti').doc(widget.progetto.nomeProgetto).set(json);
  }
}