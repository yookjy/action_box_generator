import 'dart:async';

import 'package:action_box/action_box.dart';

@ActionConfig(
    alias: 'e', parents: ['ui.common.etc', 'gateway.common', 'ui.common'])
class E extends Action<void, void> {
  @override
  FutureOr<Stream<void>> process(void param) {
    // TODO: implement process
    throw UnimplementedError();
  }
}
