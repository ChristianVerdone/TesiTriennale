import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tesi_triennale/visualizza_progetti.dart';
import 'app_state.dart';
import 'progetto.dart';

class ModifyProgetto extends StatefulWidget {
  final Progetto progetto;

  const ModifyProgetto({super.key, required this.progetto});

  @override
  State<ModifyProgetto> createState() => _ModifyProgettoState();
}

class _ModifyProgettoState extends State<ModifyProgetto> {
  bool _isA5 = false;
  bool _isA1 = false;

  @override
  void initState() {
    super.initState();
    _isA5 = widget.progetto.isA5;
    _isA1 = widget.progetto.isA1;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
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
                'Anno': widget.progetto.anno,
                'Valore': widget.progetto.valore,
                'Costi Diretti': widget.progetto.costiDiretti,
                'Costi Indiretti': widget.progetto.costiIndiretti,
                'isEconomico': widget.progetto.isEconomico,
                'isA1': _isA1,
                'isA5': _isA5,
                'Percentuale': widget.progetto.perc,
                'Contributo Competenza': widget.progetto.contributo,
                'CostiDirettiValue': widget.progetto.references,
              };
              await setFunction(appState, json);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VisualizzaProg()));
            },
          ),
        ],
        centerTitle: true,
        title: Text('Modifica Progetto: ${widget.progetto.nomeProgetto}',
            style: const TextStyle(color: Colors.black, fontSize: 20.0)),
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
          const SizedBox(height: 20),
          const Text('Fa parte di A5?:'),
          Checkbox(
            key: GlobalKey(),
            value: _isA5,
            onChanged: (bool? value) {
              setState(() {
                _isA5 = value!;
                if (_isA5) _isA1 = false;
              });
            },
          ),
          const SizedBox(height: 20),
          const Text('Fa parte di A1?:'),
          Checkbox(
            key: GlobalKey(),
            value: _isA1,
            onChanged: (bool? value) {
              setState(() {
                _isA1 = value!;
                if (_isA1) _isA5 = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> setFunction(AppState appState, Map<String, dynamic> json) async {
    await appState.progetti.doc(widget.progetto.nomeProgetto).set(json);
    await _updateA1A5(appState);
  }

  Future<void> _updateA1A5(AppState appState) async {
    final collection = _isA5 ? 'A5' : 'A1';
    final otherCollection = _isA5 ? 'A1' : 'A5';
    final docRef = appState.a1a5.doc(collection);
    final otherDocRef = appState.a1a5.doc(otherCollection);

    // Add project to the selected collection
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      final progetti = List<String>.from(data['PROGETTI'] ?? []);
      if (!progetti.contains(widget.progetto.nomeProgetto)) {
        progetti.add(widget.progetto.nomeProgetto);
        await docRef.update({'PROGETTI': progetti});
      }
    } else {
      await docRef.set({'PROGETTI': [widget.progetto.nomeProgetto]});
    }

    // Remove project from the other collection
    final otherDocSnapshot = await otherDocRef.get();
    if (otherDocSnapshot.exists) {
      final otherData = otherDocSnapshot.data() as Map<String, dynamic>;
      final otherProgetti = List<String>.from(otherData['PROGETTI'] ?? []);
      if (otherProgetti.contains(widget.progetto.nomeProgetto)) {
        otherProgetti.remove(widget.progetto.nomeProgetto);
        await otherDocRef.update({'PROGETTI': otherProgetti});
      }
    }
  }
}