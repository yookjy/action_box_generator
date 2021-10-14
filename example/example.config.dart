// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// ActionConfigGenerator
// **************************************************************************

import 'package:action_box/action_box.dart' as _i1;
import './actions/string_in_out.dart' as _i2;
import './actions/int_in_string_out.dart' as _i3;
import './actions/bool_in_out.dart' as _i4;

class ActionRoot extends _i1.ActionDirectory {
  ValueConverter get valueConverter =>
      putIfAbsentDirectory(() => ValueConverter());
}

class ValueConverter extends _i1.ActionDirectory {
  _i1.ActionDescriptor<_i2.StringInStringOut, String, String>
      get getStringInStringOutValue => putIfAbsentDescriptor(
          'getStringInStringOutValue', () => _i2.StringInStringOut());
  _i1.ActionDescriptor<_i3.IntInStringOut, int, String>
      get getIntToStringValue => putIfAbsentDescriptor(
          'getIntToStringValue', () => _i3.IntInStringOut());
  Test get test => putIfAbsentDirectory(() => Test());
}

class Test extends _i1.ActionDirectory {
  _i1.ActionDescriptor<_i4.BoolInOut, bool, bool> get getBoolValue =>
      putIfAbsentDescriptor('getBoolValue', () => _i4.BoolInOut());
}

class SpcActionCenter extends _i1.ActionCenter<ActionRoot> {
  SpcActionCenter() {
    _i1.ActionCenter.setActionDirectory(ActionRoot());
  }
}
