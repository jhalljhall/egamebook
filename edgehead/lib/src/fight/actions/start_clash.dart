import 'package:edgehead/fractal_stories/action.dart';
import 'package:edgehead/fractal_stories/actor.dart';
import 'package:edgehead/fractal_stories/pose.dart';
import 'package:edgehead/fractal_stories/simulation.dart';
import 'package:edgehead/fractal_stories/situation.dart';
import 'package:edgehead/fractal_stories/storyline/storyline.dart';
import 'package:edgehead/fractal_stories/world_state.dart';
import 'package:edgehead/src/fight/clash/clash_defense/clash_defense_situation.dart';
import 'package:edgehead/src/fight/clash/clash_situation.dart';
import 'package:edgehead/src/fight/common/conflict_chance.dart';
import 'package:edgehead/src/fight/common/defense_situation.dart';
import 'package:edgehead/src/fight/common/start_defensible_action.dart';
import 'package:edgehead/src/predetermined_result.dart';

ReasonedSuccessChance computeStartClash(
    Actor a, Simulation sim, WorldState w, Actor enemy) {
  return getCombatMoveChance(a, enemy, 0.8, [
    const Modifier(95, CombatReason.dexterity),
    const Modifier(30, CombatReason.balance),
    const Bonus(20, CombatReason.targetHasPrimaryArmDisabled),
    const Bonus(30, CombatReason.targetHasOneLegDisabled),
    const Bonus(50, CombatReason.targetHasOneEyeDisabled),
    const Bonus(50, CombatReason.targetHasAllEyesDisabled),
  ]);
}

class StartClash extends StartDefensibleActionBase {
  static const String className = "StartClash";

  static final StartClash singleton = StartClash();

  @override
  List<String> get commandPathTemplate =>
      ["attack <object>", "stance", "clash"];

  @override
  String get commandTemplate =>
      "clash with <object's> weapon to force <objectPronoun> off balance";

  @override
  String get helpMessage =>
      "This is a powerful slash directed at the enemy's weapon"
      "in order to force them off balance. "
      "The goal is not to deal damage but to "
      "force the opponent to lose control of their combat stance. It can also "
      "give members of your party an opportunity to strike.";

  @override
  String get name => className;

  @override
  bool get rerollable => false;

  @override
  Resource get rerollResource => null;

  @override
  String get rollReasonTemplate => null;

  @override
  bool get shouldShortCircuitWhenFailed => false;

  @override
  void applyShortCircuit(Actor actor, Simulation sim, WorldStateBuilder world,
      Storyline storyline, Actor enemy, Situation mainSituation) {
    throw StateError("This action doesn't short-circuit on failure.");
  }

  @override
  void applyStart(Actor actor, Simulation sim, WorldStateBuilder world,
      Storyline storyline, Actor enemy, Situation mainSituation) {
    actor.report(
        storyline,
        "<subject> {fiercely|violently} "
        "{strike<s>|hammer<s>|batter<s>} "
        "on <objectOwner's> "
        "<object>",
        objectOwner: enemy,
        object: enemy.currentWeapon);
  }

  @override
  DefenseSituation defenseSituationBuilder(Actor actor, Simulation sim,
      WorldStateBuilder world, Actor enemy, Predetermination predetermination) {
    return createClashDefenseSituation(
        world.randomInt(), actor, enemy, predetermination);
  }

  @override
  bool isApplicable(Actor a, Simulation sim, WorldState w, Actor enemy) =>
      !a.isOnGround &&
      !a.anatomy.isBlind &&
      (a.currentWeapon.damageCapability.isSlashing ||
          a.currentWeapon.damageCapability.isBlunt) &&
      (enemy.currentWeapon.damageCapability.type.canParrySlash ||
          enemy.currentWeapon.damageCapability.type.canParryBlunt) &&
      // So that you can either feint or clash, but not both.
      enemy.pose <= Pose.extended &&
      !enemy.isOnGround;

  @override
  Situation mainSituationBuilder(
      Actor actor, Simulation sim, WorldStateBuilder world, Actor enemy) {
    return createClashSituation(world.randomInt(), actor, enemy);
  }

  @override
  ReasonedSuccessChance successChanceGetter(
      Actor a, Simulation sim, WorldState w, Actor enemy) {
    return computeStartClash(a, sim, w, enemy);
  }
}