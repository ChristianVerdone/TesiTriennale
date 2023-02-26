class Conti {
  List<Conto>? conti;

  Conti({this.conti});

  Conti.fromJson(Map<String, dynamic> json) {
    if (json['conti'] != null) {
      conti = <Conto>[];
      json['conti'].forEach((v) {
        conti!.add(Conto.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (conti != null) {
      data['conti'] = this.conti!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Conto {
  String? codiceConto;
  String? descrizioneConto;
  String? dataOperazione;
  String? COD;
  String? descrizioneOperazione;
  String? numeroDocumento;
  String? dataDocumento;
  String? numeroFattura;
  String? importo;
  String? saldo;
  String? contropartita;
  bool? costiDiretti;
  bool? costiIndiretti;
  bool? attivitaEconomiche;
  bool? attivitaNonEconomiche;
  String? codiceProgetto;

  Conto(
      {this.codiceConto,
        this.descrizioneConto,
        this.dataOperazione,
        this.COD,
        this.descrizioneOperazione,
        this.numeroDocumento,
        this.dataDocumento,
        this.numeroFattura,
        this.importo,
        this.saldo,
        this.contropartita,
        this.costiDiretti,
        this.costiIndiretti,
        this.attivitaEconomiche,
        this.attivitaNonEconomiche,
        this.codiceProgetto});

  Conto.fromJson(Map<String, dynamic> json) {
    codiceConto = json['codiceConto'];
    descrizioneConto = json['descrizioneConto'];
    dataOperazione = json['dataOperazione'];
    COD = json['COD'];
    descrizioneOperazione = json['descrizioneOperazione'];
    numeroDocumento = json['numeroDocumento'];
    dataDocumento = json['dataDocumento'];
    numeroFattura = json['numeroFattura'];
    importo = json['importo'];
    saldo = json['saldo'];
    contropartita = json['contropartita'];
    costiDiretti = json['costiDiretti'];
    costiIndiretti = json['costiIndiretti'];
    attivitaEconomiche = json['attivitaEconomiche'];
    attivitaNonEconomiche = json['attivitaNonEconomiche'];
    codiceProgetto = json['codiceProgetto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
}
