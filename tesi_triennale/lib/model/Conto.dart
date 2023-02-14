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
  final dynamic costiDiretti;
  final dynamic costiIndiretti;
  final dynamic attivitaEconomiche;
  final dynamic attivitaNonEconomiche;
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
}
