import 'dart:async';

import 'package:action_box/action_box.dart';

@ActionConfig(alias: 'a', parents: ['ui.common'])
class A extends Action<void, void> {
  @override
  FutureOr<Stream<void>> process(void param) {
    // TODO: implement process
    throw UnimplementedError();
  }
}
