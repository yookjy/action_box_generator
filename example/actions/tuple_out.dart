import 'dart:async';

import 'package:action_box/action_box.dart';

@ActionConfig(
    alias: 'getTupleValue', parents: ['actionRoot', 'myDir', 'yourDir'])
class TupleOut
    extends Action<int?, List<Map<String, Tuple2<int?, List<String?>>?>?>> {
  @override
  FutureOr<Stream<List<Map<String, Tuple2<int?, List<String?>>>>>> process(
      int? param) {
    // TODO: implement process
    throw UnimplementedError();
  }
}
