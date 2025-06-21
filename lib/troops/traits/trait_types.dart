// enums/trait_type.dart
enum TraitType {
  PHYSICAL,
  MAGICAL,
  ARMORED,
  MELEE,
  RANGED,
  MAGIC_CASTER,
  FLYING,
  HEALER,
  BERSERKER,
}

extension TraitTypeExtension on TraitType {
  String get displayName {
    switch (this) {
      case TraitType.PHYSICAL:
        return "Physical";
      case TraitType.MAGICAL:
        return "Magical";
      case TraitType.ARMORED:
        return "Armored";
      case TraitType.MELEE:
        return "Melee Attacker";
      case TraitType.RANGED:
        return "Ranged Attacker";
      case TraitType.MAGIC_CASTER:
        return "Magic Caster";
      case TraitType.FLYING:
        return "Flying";
      case TraitType.HEALER:
        return "Healer";
      case TraitType.BERSERKER:
        return "Berserker";
    }
  }

  String get description {
    switch (this) {
      case TraitType.PHYSICAL:
        return "Deals physical damage to enemies.";
      case TraitType.MAGICAL:
        return "Deals magical damage, often with special effects.";
      case TraitType.ARMORED:
        return "Reduces incoming physical damage.";
      case TraitType.MELEE:
        return "Attacks foes in adjacent hexes.";
      case TraitType.RANGED:
        return "Attacks foes from a distance.";
      case TraitType.MAGIC_CASTER:
        return "Casts powerful spells, often dealing magical damage.";
      case TraitType.FLYING:
        return "Can move over obstacles and is immune to ground-based traps.";
      case TraitType.HEALER:
        return "Can restore health to allies.";
      case TraitType.BERSERKER:
        return "Gains strength as health decreases.";
    }
  }

  // You could even add properties like:
  // String get iconAssetPath => 'assets/icons/${name.toLowerCase()}.png';
}
