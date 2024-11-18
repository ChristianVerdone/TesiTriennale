import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_state.dart';

class InsertProgetto extends StatefulWidget {
  const InsertProgetto({super.key});
  @override
  _InsertProgettoState createState() => _InsertProgettoState();
}

class _InsertProgettoState extends State<InsertProgetto> {
  final TextEditingController _nomeProgettoController = TextEditingController();
  final TextEditingController _annoController = TextEditingController();
  final TextEditingController _valoreController = TextEditingController();
  final TextEditingController _contributoController = TextEditingController();
  bool _isEconomico = false;
  bool _isA5 = false;
  bool _isA1 = false;
  Map<String, dynamic> staticMap = {
    'Ammortamenti': '0',
    'God beni terzi': '0',
    'Materie Prime': '0',
    'Oneri diversi': '0',
    'Oneri finanziari': '0',
    'Personale': '0',
    'Servizi': '0'
  };
  String percentuale = '0';
  String contributo = '';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
        ),
        centerTitle: true,
        title: const Text('Inserisci Progetto', style: TextStyle(color: Colors.black, fontSize: 20.0)),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () async {
              await setFunction(appState);
              Navigator.pop(context, 'refresh');
            },
            child: const Text('Salva'),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Inserisci il nome Progetto'),
            controller: _nomeProgettoController,
            validator: (value) {
              if (value == null) {
                return 'Per favore inserisci il nome';
              }
              return null;
            },
            onFieldSubmitted: (value) {
              nomeProgetto = value;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Inserisci anno'),
            controller: _annoController,
            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null) {
                return 'Per favore inserisci anno';
              }
              return null;
            },
            onFieldSubmitted: (value) {
              anno = value;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Inserisci il Valore: euro'),
            controller: _valoreController,
            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$'))],
            validator: (value) {
              if (value == null) {
                return 'Per favore inserisci il Valore';
              }
              return null;
            },
            onFieldSubmitted: (value) {
              valore = value;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Inserisci il Contributo di Competenza dello stesso anno: euro'),
            controller: _contributoController,
            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$'))],
            validator: (value) {
              if (value == null) {
                return 'Per favore inserisci il Valore';
              }
              return null;
            },
            onFieldSubmitted: (value) {
              valore = value;
            },
          ),
          const SizedBox(height: 20),
          const Text('è Economico?:'),
          const SizedBox(height: 20),
          Checkbox(
            key: GlobalKey(),
            value: _isEconomico,
            onChanged: (bool? value) {
              setState(() {
                _isEconomico = value!;
              });
            },
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

  Future<void> setFunction(AppState appState) async {
    if (_validateInput()) {
      final json = {
        'Anno': _annoController.text,
        'Valore': _valoreController.text,
        'Costi Diretti': staticMap,
        'Costi Indiretti': staticMap,
        'isEconomico': _isEconomico,
        'isA1': _isA1,
        'isA5': _isA5,
        'Percentuale': percentuale,
        'Contributo Competenza': _contributoController.text,
        'CostiDirettiValue': [],
      };
      try {
        await appState.progetti.doc(_nomeProgettoController.text).set(json);
        await _updateA1A5(appState);
      } catch (e) {
        if (e is FirebaseException && e.code == 'permission-denied') {
          if (kDebugMode) {
            print('Permission denied. Please check your Firebase security rules.');
          }
        } else {
          if (kDebugMode) {
            print('Error: $e');
          }
        }
      }
    } else {
      if (kDebugMode) {
        print('Invalid input. Please check your data.');
      }
    }
  }

  Future<void> _updateA1A5(AppState appState) async {
    final collection = _isA5 ? 'A5' : 'A1';
    final docRef = appState.a1a5.doc(collection);
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      final progetti = List<String>.from(data['PROGETTI'] ?? []);
      if (!progetti.contains(_nomeProgettoController.text)) {
        progetti.add(_nomeProgettoController.text);
        await docRef.update({'PROGETTI': progetti});
      }
    } else {
      await docRef.set({'PROGETTI': [_nomeProgettoController.text]});
    }
  }

  bool _validateInput() {
    return _nomeProgettoController.text.isNotEmpty &&
        _annoController.text.isNotEmpty &&
        _valoreController.text.isNotEmpty &&
        _contributoController.text.isNotEmpty &&
        (_isA5 || _isA1);
  }

  @override
  void dispose() {
    _nomeProgettoController.dispose();
    _annoController.dispose();
    _valoreController.dispose();
    _contributoController.dispose();
    super.dispose();
  }

  set nomeProgetto(String value) {
    nomeProgetto = value;
  }

  set anno(String value) {
    anno = value;
  }

  set valore(String value) {
    valore = value;
  }

  set isEconomico(bool value) {
    _isEconomico = value;
  }
}