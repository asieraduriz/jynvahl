enum DamageType { physical, magical, pure }

class DamageRange {
  final double min;
  final double max;

  DamageRange(this.min, this.max);

  @override
  String toString() => 'Range($min-$max)';
}

typedef DamageProfile = Map<DamageType, DamageRange>;
