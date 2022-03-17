import 'dart:async';

import 'package:action_box/action_box.dart';

@ActionConfig(alias: 'f', parents: ['gateway.common'])
class F extends Action<void, void> {
  @override
  FutureOr<Stream<void>> process(void param) {
    // TODO: implement process
    throw UnimplementedError();
  }
}
