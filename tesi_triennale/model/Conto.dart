class Conto {
  final dynamic codiceConto;
  final dynamic descrizioneConto;
  final dynamic dataOperazione;
  final dynamic COD;
  final dynamic descrizioneOperazione;
  final dynamic numeroDocumento;
  final dynamic dataDocumento;
  final dynamic numeroFattura;
  final dynamic importo;
  final dynamic saldo;
  final dynamic contropartita;
  final bool costiDiretti;
  final bool costiIndiretti;
  final bool attivitaEconomiche;
  final bool attivitaNonEconomiche;
  final dynamic codiceProgetto;

  const Conto(
      {required this.codiceConto,
      required this.descrizioneConto,
      required this.dataOperazione,
      required this.COD,
      required this.descrizioneOperazione,
      required this.numeroDocumento,
      required this.dataDocumento,
      required this.numeroFattura,
      required this.importo,
      required this.saldo,
      required this.contropartita,
      required this.costiDiretti,
      required this.costiIndiretti,
      required this.attivitaEconomiche,
      required this.attivitaNonEconomiche,
      required this.codiceProgetto});

  Conto copy({
    dynamic codiceConto,
    dynamic descrizioneConto,
    dynamic dataOperazione,
    dynamic COD,
    dynamic descrizioneOperazione,
    dynamic numeroDocumento,
    dynamic dataDocumento,
    dynamic numeroFattura,
    dynamic importo,
    dynamic saldo,
    dynamic contropartita,
    dynamic costiDiretti,
    dynamic costiIndiretti,
    dynamic attivitaEconomiche,
    dynamic attivitaNonEconomiche,
    dynamic codiceProgetto,

  }) =>
      Conto(
        codiceConto: codiceConto ?? this.codiceConto,
        descrizioneConto: descrizioneConto ?? this.descrizioneConto,
        dataOperazione: dataOperazione ?? this.dataOperazione,
        COD: COD ?? this.COD,
        descrizioneOperazione:
            descrizioneOperazione ?? this.descrizioneOperazione,
        numeroDocumento: numeroDocumento ?? this.numeroDocumento,
        dataDocumento: dataDocumento ?? this.dataDocumento,
        numeroFattura: numeroFattura ?? this.numeroFattura,
        importo: importo ?? this.importo,
        saldo: saldo ?? this.saldo,
        contropartita: contropartita ?? this.contropartita,
        costiDiretti: costiDiretti ?? this.costiDiretti,
        costiIndiretti: costiIndiretti ?? this.costiIndiretti,
        attivitaEconomiche: attivitaEconomiche ?? this.attivitaEconomiche,
        attivitaNonEconomiche: attivitaNonEconomiche ?? this.attivitaNonEconomiche,
        codiceProgetto: codiceProgetto ?? this.codiceProgetto,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Conto &&
              runtimeType == other.runtimeType &&

              codiceConto == other.codiceConto &&
              descrizioneConto == other.descrizioneConto &&
              dataOperazione == other.dataOperazione &&
              COD == other.COD &&
              descrizioneOperazione == other.descrizioneOperazione &&
              numeroDocumento == other.numeroDocumento &&
              dataDocumento == other.dataDocumento&&
              numeroFattura == other.numeroFattura &&
              importo == other.importo &&
              saldo == other.saldo &&
              contropartita == other.contropartita &&
              costiDiretti == other.costiDiretti &&
              costiIndiretti == other.costiIndiretti &&
              attivitaEconomiche == other.attivitaEconomiche &&
              attivitaNonEconomiche == other.attivitaNonEconomiche &&
              codiceProgetto == other.codiceProgetto;

  @override
  int get hashCode => codiceConto.hashCode ^ descrizioneConto.hashCode ^ dataOperazione.hashCode ^ COD.hashCode ^ descrizioneOperazione.hashCode
                    ^ numeroDocumento.hashCode ^ dataDocumento.hashCode ^ numeroFattura.hashCode ^ importo.hashCode ^ saldo.hashCode ^ contropartita.hashCode
                    ^ costiDiretti.hashCode ^ costiIndiretti.hashCode ^ attivitaEconomiche.hashCode ^ attivitaNonEconomiche.hashCode ^ codiceProgetto.hashCode;

  static Conto fromJson(Map<String, dynamic> json) => Conto(
    codiceConto: json['Codice Conto'],
    descrizioneConto: json['Descrizione conto'],
    dataOperazione: json['Data operazione'],
    COD: json['COD'],
    descrizioneOperazione: json['Descrizione operazione'],
    numeroDocumento: json['Numero documento'],
    dataDocumento: json['Data documento'],
    numeroFattura: json['Numero fattura'],
    importo: json['Importo'],
    saldo: json['Saldo'],
    contropartita: json['Contropartita'],
    costiDiretti: json['Costi diretti'],
    costiIndiretti: json['Costi indiretti'],
    attivitaEconomiche: json['Attività economiche'],
    attivitaNonEconomiche: json['Attività non economiche'],
    codiceProgetto: json['Codice progetto'],
  );
/*
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (conti != null) {
      conti!.map((v) => v.toJson()).toList();
    }
    data['codiceConto'] = this.codiceConto;
    data['descrizioneConto'] = this.descrizioneConto;
    data['dataOperazione'] = this.dataOperazione;
    data['COD'] = this.COD;
    data['descrizioneOperazione'] = this.descrizioneOperazione;
    data['numeroDocumento'] = this.numeroDocumento;
    data['dataDocumento'] = this.dataDocumento;
    data['numeroFattura'] = this.numeroFattura;
    data['importo'] = this.importo;
    data['saldo'] = this.saldo;
    data['contropartita'] = this.contropartita;
    data['costiDiretti'] = this.costiDiretti;
    data['costiIndiretti'] = this.costiIndiretti;
    data['attivitaEconomiche'] = this.attivitaEconomiche;
    data['attivitaNonEconomiche'] = this.attivitaNonEconomiche;
    data['codiceProgetto'] = this.codiceProgetto;
    return data;
  }

 */
}
