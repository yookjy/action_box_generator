
import 'package:action_box/action_box.dart';
import 'package:action_box_generator/builder.dart';

@ActionConfig(descriptorName: 'getBoolValue', registerTo: 'valueConverter.test')
class BoolInOut extends Action<bool, bool> {

  Channel exCh1 = Channel();
  Channel exCh2 = Channel();

  @override
  Stream<bool?> process([bool? param]) {
    return Stream.value(param);
  }
}
