class Progetto{
  final dynamic nomeProgetto;
  final dynamic anno;
  final dynamic valore;
  final Map<String, dynamic> costiDiretti;
  final Map<String, dynamic> costiIndiretti;

  const Progetto.prog({required this.nomeProgetto,
    required this.anno,
    required this.valore,
    required this.costiDiretti,
    required this.costiIndiretti
  });

  const Progetto.empty(this.nomeProgetto,
      this.anno, this.valore,
      this.costiDiretti,
      this.costiIndiretti);
}