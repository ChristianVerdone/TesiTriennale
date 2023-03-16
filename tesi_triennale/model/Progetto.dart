class Progetto{
  final dynamic nomeProgetto;
  final dynamic anno;
  final dynamic valore;
  final Map<String, dynamic> costiDiretti;
  final Map<String, dynamic> costiIndiretti;
  final bool isEconomico;
  final dynamic perc;
  final dynamic contributo;

  const Progetto.prog({required this.nomeProgetto,
    required this.anno,
    required this.valore,
    required this.costiDiretti,
    required this.costiIndiretti,
    required this.isEconomico,
    required this.perc,
    required this.contributo
  });
}