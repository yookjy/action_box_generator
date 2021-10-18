
import 'package:action_box/action_box.dart';

@ActionConfig(descriptorName: 'getBoolValue', registerTo: 'valueConverter.testDir')
class BoolInOut extends Action<bool, bool> {

  Channel exCh1 = Channel();
  Channel exCh2 = Channel();

  @override
  Stream<bool?> process([bool? param]) {
    return Stream.value(param);
  }
}
