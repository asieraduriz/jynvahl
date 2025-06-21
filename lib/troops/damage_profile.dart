enum DamageType { physical, magical, pure }

class DamageProfile {
  final Map<DamageType, double> damages;

  const DamageProfile(this.damages);

  @override
  String toString() {
    return damages.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.value.toStringAsFixed(2)} ${e.key.name}')
        .join(', ');
  }
}
