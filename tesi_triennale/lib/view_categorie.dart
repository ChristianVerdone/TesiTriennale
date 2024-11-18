import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesi_triennale/utils.dart';
import 'view_conti_cat.dart';
import 'app_state.dart';

class VisualizzaCatPage extends StatefulWidget {
  const VisualizzaCatPage({super.key});
  @override
  State<VisualizzaCatPage> createState() => _VisualizzaCatPageState();
}

class _VisualizzaCatPageState extends State<VisualizzaCatPage> {
  List<String> cat = [];
  Map<String, dynamic>? riepilogoCatData;
  Map<String, dynamic>? valoreProduzione;
  bool isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    getCat(); // Call getCat in initState
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Categorie'),
        actions: <Widget>[
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
            icon: const Icon(Icons.home),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: isLoading // Show a loading indicator while fetching data
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Valore della Produzione: '
                            '${valoreProduzione!['ValoreProduzione']?.toStringAsFixed(2) ?? 'N/A'}'),
                        Text('Valore della Produzione Attivit\u00E0 Economiche: '
                            '${valoreProduzione!['ValoreProduzioneE']?.toStringAsFixed(2) ?? 'N/A'} '
                            '(${valoreProduzione!['percTotProgettiE']?.toStringAsFixed(2) ?? 'N/A'}%)'),
                        Text('Valore della Produzione Attivit\u00E0 Non Economiche + Altri: '
                            '${valoreProduzione!['ValoreProduzioneNonE']?.toStringAsFixed(2) ?? 'N/A'} '
                            '(${valoreProduzione!['percValoreProduzioneNonE']?.toStringAsFixed(2) ?? 'N/A'}%)'),
                        Text('Valore della Produzione Progetti Economici: '
                            '${valoreProduzione!['totProgettiE']?.toStringAsFixed(2) ?? 'N/A'}'),
                        Text('Valore della Produzione Progetti Non Economici: '
                            '${valoreProduzione!['totProgettinE']?.toStringAsFixed(2) ?? 'N/A'}'),
                      ],
                    ),
                  ),
                  if (riepilogoCatData != null) // Display riepilogoCat data if available
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Costi di produzione: '
                              '${riepilogoCatData!['Costi di produzione']?.toStringAsFixed(2) ?? 'N/A'}'),
                          Text('Costi di produzione Attivit\u00E0 Economiche: '
                              '${riepilogoCatData!['totCostiAttEco']?.toStringAsFixed(2) ?? 'N/A'} '
                              ' (${valoreProduzione!['percTotProgettiE']?.toStringAsFixed(2) ?? 'N/A'}%)'),
                          Text('Costi di produzione Attivit\u00E0 Non Economiche: '
                              '${riepilogoCatData!['totCostiAttNonEco']?.toStringAsFixed(2) ?? 'N/A'} '
                              ' (${valoreProduzione!['percValoreProduzioneNonE']?.toStringAsFixed(2) ?? 'N/A'}%)'),
                          const Text('Costi diretti:'),
                          Text('  Attivit\u00E0 economiche: '
                              '${riepilogoCatData!['totCostiDirettiAttEco']?.toStringAsFixed(2) ?? 'N/A'}'),
                          Text('  Attivit\u00E0 non economiche: '
                              '${riepilogoCatData!['totCostiDirettiAttNonEco']?.toStringAsFixed(2) ?? 'N/A'}'),
                          const Text('Costi indiretti:'),
                          Text('  Attivit\u00E0 economiche: '
                              '${riepilogoCatData!['totCostiIndirettiAttEco']?.toStringAsFixed(2) ?? 'N/A'}'),
                          Text('  Attivit\u00E0 non economiche: '
                              '${riepilogoCatData!['totCostiIndirettiAttNonEco']?.toStringAsFixed(2) ?? 'N/A'}'),
                        ],
                      ),
                    ),
                  ]),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cat.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewContiCatPage(idCat: cat[index]),
                                ),
                              );
                            },
                            child: Text(cat[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> getCat() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.categorie.get().then(
      (value) => value.docs.forEach((categ) {
        if (categ.id != 'riepilogoCat' && categ.id != 'Valore della Produzione') {
          cat.add(categ.id);
        } else if (categ.id == 'riepilogoCat') {
          riepilogoCatData = categ.data() as Map<String, dynamic>?;
        } else if (categ.id == 'Valore della Produzione') {
          valoreProduzione = categ.data() as Map<String, dynamic>?;
        }
      }),
    );
    await calcolaEInserisciRiepilogoCat(context);
    setState(() {
      isLoading = false;
    });
  }
}