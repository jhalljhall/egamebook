import 'package:edgehead/fractal_stories/action.dart';
import 'package:edgehead/fractal_stories/actor.dart';
import 'package:edgehead/fractal_stories/item.dart';
import 'package:edgehead/fractal_stories/storyline/randomly.dart';
import 'package:edgehead/fractal_stories/storyline/storyline.dart';
import 'package:edgehead/fractal_stories/world.dart';

class OnGroundParry extends EnemyTargetActorAction {
  OnGroundParry(Actor enemy) : super(enemy);

  @override
  String get nameTemplate => "parry it";

  @override
  String applyFailure(Actor a, WorldState _, Storyline s) {
    a.report(
        s,
        "<subject> tr<ies> to {parry|deflect it|"
        "stop it{| with <subject's> ${a.currentWeapon.name}}}");
    Randomly.run(
        () => a.report(s, "<subject> {fail<s>|<does>n't succeed}", but: true),
        () => enemy.report(s, "<subject> <is> too quick for <object>",
            object: a, but: true));
    return "${a.name} fails to parry ${enemy.name}";
  }

  @override
  String applySuccess(Actor a, WorldState w, Storyline s) {
    a.report(
        s,
        "<subject> {parr<ies> it|"
        "stop<s> it with <subject's> ${a.currentWeapon.name}}",
        positive: true);
    w.popSituationsUntil("FightSituation");
    return "${a.name} parries ${enemy.name}";
  }

  @override
  num getSuccessChance(Actor a, WorldState world) {
    if (a.isPlayer) return 0.6;
    return 0.3;
  }

  @override
  bool isApplicable(Actor a, WorldState world) => a.wields(ItemType.SWORD);

  static EnemyTargetActorAction builder(Actor enemy) =>
      new OnGroundParry(enemy);
}
