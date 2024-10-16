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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Progetto &&
          runtimeType == other.runtimeType &&
          nomeProgetto == other.nomeProgetto &&
          anno == other.anno &&
          valore == other.valore &&
          costiDiretti == other.costiDiretti &&
          costiIndiretti == other.costiIndiretti &&
          isEconomico == other.isEconomico &&
          perc == other.perc &&
          contributo == other.contributo &&
          references == other.references;

  @override
  int get hashCode =>
      nomeProgetto.hashCode ^
      anno.hashCode ^
      valore.hashCode ^
      costiDiretti.hashCode ^
      costiIndiretti.hashCode ^
      isEconomico.hashCode ^
      perc.hashCode ^
      contributo.hashCode ^
      references.hashCode;

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