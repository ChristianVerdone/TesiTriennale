
class Progetto{
  final dynamic nomeProgetto;
  final dynamic anno;
  final dynamic valore;
  final List<Map<String, dynamic>> costiDiretti;
  final List<Map<String, dynamic>> costiIndiretti;

  const Progetto({required this.nomeProgetto,
    required this.anno,
    required this.valore,
    required this.costiDiretti,
    required this.costiIndiretti
  });
}