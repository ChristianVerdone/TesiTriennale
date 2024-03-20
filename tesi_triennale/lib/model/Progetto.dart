class Progetto{
  late final dynamic nomeProgetto;
  late final dynamic anno;
  late final dynamic valore;
  late final Map<String, dynamic> costiDiretti;
  late final Map<String, dynamic> costiIndiretti;
  late final bool isEconomico;
  late final dynamic perc;
  late final dynamic contributo;

  Progetto.prog({required this.nomeProgetto,
    required this.anno,
    required this.valore,
    required this.costiDiretti,
    required this.costiIndiretti,
    required this.isEconomico,
    required this.perc,
    required this.contributo
  });


}