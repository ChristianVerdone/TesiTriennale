import 'dart:collection';

class Conto {
  final dynamic codiceConto;
  final dynamic descrizioneConto;
  final dynamic dataOperazione;
  final dynamic descrizioneOperazione;
  final dynamic numeroDocumento;
  final dynamic dataDocumento;
  final dynamic importo;
  final dynamic saldo;
  final dynamic contropartita;
  final bool costiDiretti;
  final bool costiIndiretti;
  final bool attivitaEconomiche;
  final bool attivitaNonEconomiche;
  final dynamic codiceProgetto;
  final LinkedHashMap<String, double>? projectAmounts;

  const Conto(
      {required this.codiceConto,
      required this.descrizioneConto,
      required this.dataOperazione,
      required this.descrizioneOperazione,
      required this.numeroDocumento,
      required this.dataDocumento,
      required this.importo,
      required this.saldo,
      required this.contropartita,
      required this.costiDiretti,
      required this.costiIndiretti,
      required this.attivitaEconomiche,
      required this.attivitaNonEconomiche,
      required this.codiceProgetto,
      this.projectAmounts});

  Conto copy({
    dynamic codiceConto,
    dynamic descrizioneConto,
    dynamic dataOperazione,
    dynamic descrizioneOperazione,
    dynamic numeroDocumento,
    dynamic dataDocumento,
    dynamic importo,
    dynamic saldo,
    dynamic contropartita,
    dynamic costiDiretti,
    dynamic costiIndiretti,
    dynamic attivitaEconomiche,
    dynamic attivitaNonEconomiche,
    dynamic codiceProgetto, 
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
        saldo: saldo ?? this.saldo,
        contropartita: contropartita ?? this.contropartita,
        costiDiretti: costiDiretti ?? this.costiDiretti,
        costiIndiretti: costiIndiretti ?? this.costiIndiretti,
        attivitaEconomiche: attivitaEconomiche ?? this.attivitaEconomiche,
        attivitaNonEconomiche: attivitaNonEconomiche ?? this.attivitaNonEconomiche,
        codiceProgetto: codiceProgetto ?? this.codiceProgetto,
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
              saldo == other.saldo &&
              contropartita == other.contropartita &&
              costiDiretti == other.costiDiretti &&
              costiIndiretti == other.costiIndiretti &&
              attivitaEconomiche == other.attivitaEconomiche &&
              attivitaNonEconomiche == other.attivitaNonEconomiche &&
              codiceProgetto == other.codiceProgetto;

  @override
  int get hashCode => codiceConto.hashCode ^ descrizioneConto.hashCode ^ dataOperazione.hashCode ^
                      descrizioneOperazione.hashCode ^ numeroDocumento.hashCode ^ dataDocumento.hashCode ^
                      importo.hashCode ^ saldo.hashCode ^ contropartita.hashCode ^ costiDiretti.hashCode ^ costiIndiretti.hashCode ^
                      attivitaEconomiche.hashCode ^ attivitaNonEconomiche.hashCode ^ codiceProgetto.hashCode;

  static Conto fromJson(Map<String, dynamic> json) => Conto(
    codiceConto: json['Codice Conto'],
    descrizioneConto: json['Descrizione conto'],
    dataOperazione: json['Data operazione'],
    descrizioneOperazione: json['Descrizione operazione'],
    numeroDocumento: json['Numero documento'],
    dataDocumento: json['Data documento'],
    importo: json['Importo'],
    saldo: json['Saldo'],
    contropartita: json['Contropartita'],
    costiDiretti: json['Costi diretti'],
    costiIndiretti: json['Costi indiretti'],
    attivitaEconomiche: json['Attività economiche'],
    attivitaNonEconomiche: json['Attività non economiche'],
    codiceProgetto: json['Codice progetto'],
  );

   List<dynamic> toList(){
    return [//codiceConto, descrizioneConto,
      dataOperazione, descrizioneOperazione, numeroDocumento, dataDocumento, importo, saldo, contropartita,
      costiDiretti, costiIndiretti, attivitaEconomiche, attivitaNonEconomiche, codiceProgetto
    ];
  }

  List<dynamic> toListF(){
    return [codiceConto, descrizioneConto, dataOperazione, descrizioneOperazione, numeroDocumento, dataDocumento,
      importo, saldo, contropartita, costiDiretti, costiIndiretti, attivitaEconomiche, attivitaNonEconomiche, codiceProgetto
    ];
  }
}