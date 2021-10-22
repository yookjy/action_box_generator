import 'package:action_box/action_box.dart';

@ActionConfig(
    alias: 'getBoolValue', parents: ['actionRoot', 'myDir', 'yourDir'])
class BoolInOut extends Action<bool, dynamic> {
  Channel exCh1 = Channel();
  Channel exCh2 = Channel();

  @override
  Stream<dynamic> process([bool? param]) {
    return Stream.value(param);
  }
}
