class Conto {
  final String CodiceConto;
  final String DescrizioneConto;
  final DateTime DataOperazione;
  final int COD;
  final String DescrizioneOperazione;
  final String NumeroDocumento;
  final DateTime DataDocumento;
  final int NumeroFattura;
  final double Importo;
  final double Saldo;
  final String Contropartita;
  final bool CostiDiretti;
  final bool CostiIndiretti;
  final bool AttivitaEconomiche;
  final bool AttivitaNonEconomiche;
  final String CodiceProgetto;

  const Conto({
    required this.CodiceConto,
    required this.DescrizioneConto,
    required this.DataOperazione,
    required this.COD,
    required this.DescrizioneOperazione,
    required this.NumeroDocumento,
    required this.DataDocumento,
    required this.NumeroFattura,
    required this.Importo,
    required this.Saldo,
    required this.Contropartita,
    this.CostiDiretti = false,
    this.CostiIndiretti = false,
    this.AttivitaEconomiche = false,
    this.AttivitaNonEconomiche = false,
    this.CodiceProgetto = ''
  });

  Conto copy({
    String? CodiceConto,
    String? DescrizioneConto,
    DateTime? DataOperazione,
    int? COD,
    String? DescrizioneOperazione,
    String? NumeroDocumento,
    DateTime? DataDocumento,
    int? NumeroFattura,
    double? Importo,
    double? Saldo,
    String? Contropartita,
  }) =>
      Conto(
        CodiceConto: CodiceConto ?? this.CodiceConto,
        DescrizioneConto: DescrizioneConto ?? this.DescrizioneConto,
        DataOperazione: DataOperazione ?? this.DataOperazione,
        COD: COD ?? this.COD,
        DescrizioneOperazione: DescrizioneOperazione ?? this.DescrizioneOperazione,
        NumeroDocumento: NumeroDocumento ?? this.NumeroDocumento,
        DataDocumento: DataDocumento ?? this.DataDocumento,
        NumeroFattura: NumeroFattura ?? this.NumeroFattura,
        Importo: Importo ?? this.Importo,
        Saldo: Saldo ?? this.Saldo,
        Contropartita: Contropartita ?? this.Contropartita,
      );
}