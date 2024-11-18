import 'dart:collection';

class Conto {
  final String codiceConto;
  final String descrizioneConto;
  final String dataOperazione;
  final String descrizioneOperazione;
  final String numeroDocumento;
  final String dataDocumento;
  final String importo;
  final String contropartita;
  final bool costiDiretti;
  final bool costiIndiretti;
  final bool attivitaEconomiche;
  final bool attivitaNonEconomiche;
  final String codiceProgetto;
  final String codiceFiscale;
  final String partitaIva;
  final LinkedHashMap<String, double>? projectAmounts;

  Conto({
    required this.codiceConto,
    required this.descrizioneConto,
    required this.dataOperazione,
    required this.descrizioneOperazione,
    required this.numeroDocumento,
    required this.dataDocumento,
    required this.importo,
    required this.contropartita,
    required this.costiDiretti,
    required this.costiIndiretti,
    required this.attivitaEconomiche,
    required this.attivitaNonEconomiche,
    required this.codiceProgetto,
    required this.codiceFiscale,
    required this.partitaIva,
    this.projectAmounts,
  });

  Conto copy({
    String? codiceConto,
    String? descrizioneConto,
    String? dataOperazione,
    String? descrizioneOperazione,
    String? numeroDocumento,
    String? dataDocumento,
    String? importo,
    String? contropartita,
    bool? costiDiretti,
    bool? costiIndiretti,
    bool? attivitaEconomiche,
    bool? attivitaNonEconomiche,
    String? codiceProgetto,
    String? codiceFiscale,
    String? partitaIva,
    LinkedHashMap<String, double>? projectAmounts,
  }) =>
      Conto(
        codiceConto: codiceConto ?? this.codiceConto,
        descrizioneConto: descrizioneConto ?? this.descrizioneConto,
        dataOperazione: dataOperazione ?? this.dataOperazione,
        descrizioneOperazione: descrizioneOperazione ?? this.descrizioneOperazione,
        numeroDocumento: numeroDocumento ?? this.numeroDocumento,
        dataDocumento: dataDocumento ?? this.dataDocumento,
        importo: importo ?? this.importo,
        contropartita: contropartita ?? this.contropartita,
        costiDiretti: costiDiretti ?? this.costiDiretti,
        costiIndiretti: costiIndiretti ?? this.costiIndiretti,
        attivitaEconomiche: attivitaEconomiche ?? this.attivitaEconomiche,
        attivitaNonEconomiche: attivitaNonEconomiche ?? this.attivitaNonEconomiche,
        codiceProgetto: codiceProgetto ?? this.codiceProgetto,
        codiceFiscale: codiceFiscale ?? this.codiceFiscale,
        partitaIva: partitaIva ?? this.partitaIva,
        projectAmounts: projectAmounts ?? this.projectAmounts,
      );


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Conto &&
              runtimeType == other.runtimeType &&
              codiceConto == other.codiceConto &&
              descrizioneConto == other.descrizioneConto &&
              dataOperazione == other.dataOperazione &&
              descrizioneOperazione == other.descrizioneOperazione &&
              numeroDocumento == other.numeroDocumento &&
              dataDocumento == other.dataDocumento&&
              importo == other.importo &&
              contropartita == other.contropartita &&
              costiDiretti == other.costiDiretti &&
              costiIndiretti == other.costiIndiretti &&
              attivitaEconomiche == other.attivitaEconomiche &&
              attivitaNonEconomiche == other.attivitaNonEconomiche &&
              codiceProgetto == other.codiceProgetto;

  @override
  int get hashCode => codiceConto.hashCode ^ descrizioneConto.hashCode ^ dataOperazione.hashCode ^
                      descrizioneOperazione.hashCode ^ numeroDocumento.hashCode ^ dataDocumento.hashCode ^
                      importo.hashCode ^ contropartita.hashCode ^ costiDiretti.hashCode ^ costiIndiretti.hashCode ^
                      attivitaEconomiche.hashCode ^ attivitaNonEconomiche.hashCode ^ codiceProgetto.hashCode;

  static Conto fromJson(Map<String, dynamic> json) => Conto(
    codiceConto: json['Codice Conto'],
    descrizioneConto: json['Descrizione conto'],
    dataOperazione: json['Data operazione'],
    descrizioneOperazione: json['Descrizione operazione'],
    numeroDocumento: json['Numero documento'],
    dataDocumento: json['Data documento'],
    importo: json['Importo'],
    contropartita: json['Contropartita'],
    costiDiretti: json['Costi diretti'],
    costiIndiretti: json['Costi indiretti'],
    attivitaEconomiche: json['Attività economiche'],
    attivitaNonEconomiche: json['Attività non economiche'],
    codiceProgetto: json['Codice progetto'], codiceFiscale: json['Codice Fiscale'], partitaIva: json['Partita IVA'],
  );

  List<dynamic> toList() {
    return [
      dataOperazione,
      descrizioneOperazione,
      numeroDocumento,
      dataDocumento,
      importo,
      contropartita,
      costiDiretti,
      costiIndiretti,
      attivitaEconomiche,
      attivitaNonEconomiche,
      codiceProgetto,
      codiceFiscale,
      partitaIva,
    ];
  }

  List<dynamic> toListF(){
    return [codiceConto, descrizioneConto, dataOperazione, descrizioneOperazione, dataDocumento, numeroDocumento,
      importo, //saldo,
      codiceFiscale, partitaIva,
      contropartita, costiDiretti, costiIndiretti, attivitaEconomiche, attivitaNonEconomiche, codiceProgetto, projectAmounts
    ];
  }

  List<dynamic> toListFPAmounts(String project){
    return [codiceConto, descrizioneConto, dataOperazione, descrizioneOperazione, dataDocumento, numeroDocumento,
      importo, //saldo,
      codiceFiscale, partitaIva,
      contropartita, costiDiretti, costiIndiretti, attivitaEconomiche, attivitaNonEconomiche, codiceProgetto, projectAmounts?.containsKey(project) == true ? projectAmounts![project] : 0.0
    ];
  }
}