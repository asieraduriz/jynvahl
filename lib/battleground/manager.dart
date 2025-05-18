enum BattleState { placing, playerTurn, opponentTurn, finished }

class BattlegroundManager {
  String mapId;

  BattlegroundManager({required this.mapId});

  BattleState battleState = BattleState.placing;
}
