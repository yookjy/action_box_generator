import 'dart:async';

import 'package:action_box/action_box.dart';

@ActionConfig(alias: 'd', parents: ['ui.common'])
class D extends Action<void, void> {
  @override
  FutureOr<Stream<void>> process(void param) {
    // TODO: implement process
    throw UnimplementedError();
  }
}
