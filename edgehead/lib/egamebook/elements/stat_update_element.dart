library egamebook.element.stat_update;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:edgehead/stat.dart';

import 'element_base.dart';

part 'stat_update_element.g.dart';

abstract class StatUpdate<T> extends ElementBase
    implements Built<StatUpdate<T>, StatUpdateBuilder<T>> {
  static Serializer<StatUpdate> get serializer => _$statUpdateSerializer;

  factory StatUpdate([void updates(StatUpdateBuilder<T> b)]) = _$StatUpdate<T>;

  StatUpdate._();

  /// The change of the value, e.g. `-1`.
  T get change;

  /// Name of the stat. Corresponds to [Stat.name].
  String get name;

  /// The value of the stat after the update, e.g. `2`.
  T get newValue;

  /// The kind of stat that this update is changing.
  ///
  /// This is a safety/convenience getter to prevent string-checking
  /// (`name == "stamina"`) in client code.
  StatUpdateType get type {
    switch (name) {
      case "stamina":
        return StatUpdateType.stamina;
      case "sanity":
        return StatUpdateType.sanity;
    }
    throw StateError('unsupported type: name=$name');
  }

  /// Creates a sanity update.
  static StatUpdate sanity(int initial, int change) {
    return StatUpdate<int>((b) => b
      ..name = "sanity"
      ..change = change
      ..newValue = initial + change);
  }

  /// Creates a stamina update.
  static StatUpdate stamina(int initial, int change) {
    return StatUpdate<int>((b) => b
      ..name = "stamina"
      ..change = change
      ..newValue = initial + change);
  }
}

enum StatUpdateType {
  sanity,
  stamina,
}
