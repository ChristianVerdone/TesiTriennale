class Progetto{
  dynamic nomeProgetto;
  dynamic anno;
  dynamic valore;
  late final Map<String, dynamic> costiDiretti;
  late final Map<String, dynamic> costiIndiretti;
  bool isEconomico;
  late final dynamic perc;
  dynamic contributo;
  late final List references;

  Progetto.prog({required this.nomeProgetto,
    required this.anno,
    required this.valore,
    required this.costiDiretti,
    required this.costiIndiretti,
    required this.isEconomico,
    required this.perc,
    required this.contributo,
    required this.references
  });
}